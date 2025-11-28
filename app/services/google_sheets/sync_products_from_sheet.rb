require "google/apis/sheets_v4"
require "googleauth"

module GoogleSheets
  class SyncProductsFromSheet
    SCOPE = [
      "https://www.googleapis.com/auth/spreadsheets"
    ].freeze

    def initialize(spreadsheet_id:, range:)
      @spreadsheet_id = spreadsheet_id
      @range = range

      @service = Google::Apis::SheetsV4::SheetsService.new
      @service.client_options.application_name = "ProductsSyncCase"
      @service.authorization = authorize
    end

    def call
      response = @service.get_spreadsheet_values(@spreadsheet_id, @range)
      rows = response.values || []
      return 0 if rows.empty?

      header = rows.shift
      sheet_name = @range.split("!").first

      synced_count = 0

      ActiveRecord::Base.transaction do
        rows.each_with_index do |row, index|
          attrs = build_attributes_from_row(header, row)
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
            clear_error_cell(sheet_name, index)
          else
            error_message = product.errors.full_messages.join(", ")
            Rails.logger.warn(
              "Product validation failed for row #{row.inspect} - errors: #{error_message}"
            )
            write_error_to_sheet(sheet_name, index, error_message)
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
      data = header.zip(row).to_h.symbolize_keys

      {
        id:       data[:id].presence,
        name:     data[:name],
        price:    data[:price].presence && data[:price].to_f,
        stock:    data[:stock].presence && data[:stock].to_i,
        category: data[:category]
      }
    end

    def write_error_to_sheet(sheet_name, row_index, error_message)
      sheet_row = row_index + 2
      error_range = "#{sheet_name}!F#{sheet_row}"

      value_range = Google::Apis::SheetsV4::ValueRange.new(
        values: [ [ error_message ] ]
      )

      @service.update_spreadsheet_value(
        @spreadsheet_id,
        error_range,
        value_range,
        value_input_option: "RAW"
      )
    end

    def clear_error_cell(sheet_name, row_index)
      sheet_row = row_index + 2
      error_range = "#{sheet_name}!F#{sheet_row}"

      value_range = Google::Apis::SheetsV4::ValueRange.new(
        values: [ [ "" ] ]
      )

      @service.update_spreadsheet_value(
        @spreadsheet_id,
        error_range,
        value_range,
        value_input_option: "RAW"
      )
    end
  end
end
