require "google/apis/sheets_v4"
require "googleauth"

module GoogleSheets
  class SyncProductsFromSheet
    SCOPE = [
      "https://www.googleapis.com/auth/spreadsheets.readonly"
    ].freeze

    def initialize(spreadsheet_id:, range:)
      @spreadsheet_id = spreadsheet_id
      @range = range

      @service = Google::Apis::SheetsV4::SheetsService.new
      @service.client_options.application_name = "ProductsSyncCase"
      @service.authorization = authorize
    end

    def call
      # Google Sheet'ten satırları çek
      response = @service.get_spreadsheet_values(@spreadsheet_id, @range)
      rows = response.values || []

      # Sheet boşsa çık
      return 0 if rows.empty?

      # İlk satırı başlık kabul ediyoruz: id | name | price | stock | category
      header = rows.shift

      synced_count = 0

      ActiveRecord::Base.transaction do
        rows.each do |row|
          attrs = build_attributes_from_row(header, row)

          # name boşsa kaydetmeye çalışma
          next if attrs[:name].blank?

          product = if attrs[:id].present?
                      Product.find_or_initialize_by(id: attrs[:id])
          else
                      Product.find_or_initialize_by(name: attrs[:name])
          end

          product.assign_attributes(attrs.except(:id))

          if product.valid?
            product.save!
            synced_count += 1
          else
            Rails.logger.warn(
              "Product validation failed for row #{row.inspect} - errors: #{product.errors.full_messages}"
            )
            # İleride istersen bu hataları Sheet'e de yazabiliriz
          end
        end
      end

      synced_count
    end

    private

    def authorize
      credentials_file = Rails.root.join("config", "google_service_account.json")

      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(credentials_file),
        scope: SCOPE
      )
    end

    def build_attributes_from_row(header, row)
      # ["id", "name", "price"...] + ["1", "iPhone", "1000"...] -> { id: "1", name: "iPhone", ... }
      data = header.zip(row).to_h.symbolize_keys

      {
        id:       data[:id].presence,
        name:     data[:name],
        price:    data[:price].presence && data[:price].to_f,
        stock:    data[:stock].presence && data[:stock].to_i,
        category: data[:category]
      }
    end
  end
end
