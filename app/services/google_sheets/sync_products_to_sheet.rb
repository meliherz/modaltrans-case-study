require "google/apis/sheets_v4"
require "googleauth"

module GoogleSheets
  class SyncProductsToSheet
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
      products = Product.order(:id)

      values = []
      values << [ "id", "name", "price", "stock", "category", "error" ]

      products.each do |product|
        values << [
          product.id,
          product.name,
          product.price,
          product.stock,
          product.category,
          "" # error kolonunu outbound sync'te temiz tutuyoruz
        ]
      end

      clear_range

      value_range = Google::Apis::SheetsV4::ValueRange.new(values: values)
      @service.update_spreadsheet_value(
        @spreadsheet_id,
        @range,
        value_range,
        value_input_option: "RAW"
      )

      products.count
    end

    private

    def authorize
      credentials_file = Rails.root.join("config", "google_service_account.json")

      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(credentials_file),
        scope: SCOPE
      )
    end

    def clear_range
      clear_request = Google::Apis::SheetsV4::ClearValuesRequest.new
      @service.clear_values(@spreadsheet_id, @range, clear_request)
    end
  end
end
