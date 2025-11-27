class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

 # POST /products/sync
 def sync
  spreadsheet_id = ENV.fetch("GOOGLE_PRODUCTS_SHEET_ID", nil)
  range = "Products!A2:E1000" # Sheet sayfa adı ve kolon aralığı

  if spreadsheet_id.blank?
    redirect_to products_path, alert: "Spreadsheet ID is not configured."
    return
  end

  service = GoogleSheets::SyncProductsFromSheet.new(
    spreadsheet_id: spreadsheet_id,
    range: range
  )

  synced_count = service.call

  redirect_to products_path, notice: "Sync completed. #{synced_count} products processed."
 end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, notice: "Product was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_product
      @product = Product.find(params.expect(:id))
    end

    def product_params
      params.expect(product: [ :name, :price, :stock, :category ])
    end
end
