# Products Sync Case Study — Ruby on Rails + Google Sheets

This project is a case study implementation demonstrating a two-way synchronization system between a **Ruby on Rails application** and **Google Sheets**.

The goal is to keep a Rails `Product` database table and a Google Sheet **perfectly in sync**, while ensuring data consistency, clean architecture, and maintainable code.

---

## 🚀 FEATURES

### ✔ One-Way Sync (Google Sheet → Rails DB)

* Reads product data from a Google Sheet.
* Creates new products or updates existing ones.
* Does not auto-delete rows (safe-sync).
* Supports model validations.
* Writes validation errors directly into the Sheet’s **error** column.
* Idempotent — running sync repeatedly is safe.

### ✔ Two-Way Sync (Rails DB → Google Sheet)

* Pushes all products from the database back into the Google Sheet.
* Clears the target range before writing.
* Writes header + rows in batch.
* Guarantees that Sheet always mirrors DB state.

### ✔ Architecture

* Clean, maintainable service objects:

  * `GoogleSheets::SyncProductsFromSheet`
  * `GoogleSheets::SyncProductsToSheet`
* Controller remains small; business logic stays in services.
* RESTful routes with custom sync actions.

---

## 📦 TECHNOLOGY STACK

* **UI Framework:** Bootstrap 5 (via CDN)

* **Backend:** Ruby on Rails 8.x

* **Database:** SQLite

* **External API:** Google Sheets API v4

* **Authorization:** Google Service Account

* **ENV Management:** dotenv-rails

* **Architecture:** MVC + Service Objects

---

## 📁 PROJECT STRUCTURE

```
app/
 ├── controllers/products_controller.rb
 ├── models/product.rb
 └── services/google_sheets/
      ├── sync_products_from_sheet.rb
      └── sync_products_to_sheet.rb

config/
 ├── routes.rb
 └── google_service_account.json (ignored by Git)
```

---

## 🛠 SETUP GUIDE

### 1️⃣ Clone Project

```
git clone https://github.com/meliherz/modaltrans-case-study.git
cd modaltrans-case-study
```

### 2️⃣ Install Dependencies

```
bundle install
```

### 3️⃣ Add `.env.local`

```
GOOGLE_PRODUCTS_SHEET_ID=YOUR_SHEET_ID_HERE
```

### 4️⃣ Add Google Service Account Credentials

Place service account JSON here:

```
config/google_service_account.json
```

Make sure it is gitignored.

### 5️⃣ Share Sheet With Service Account

Give **Editor** permission.

---

## 🔄 SYNCHRONIZATION WORKFLOW

### 🔁 Google Sheet → Rails (Import)

* Reads sheet rows via API
* Maps columns: id, name, price, stock, category, error
* Validates each row
* Saves valid records
* Writes validation errors into sheet

### 🔁 Rails → Google Sheet (Export)

* Fetches all products
* Clears sheet range
* Writes header + all rows
* Ensures sheet = database state

---

## 🧩 ROUTES

```
resources :products do
  post :sync, on: :collection          # Sheet → DB
  post :sync_to_sheet, on: :collection # DB → Sheet
end
```

---

## 🧪 VALIDATIONS

* `name` required
* numeric casting for price/stock
* invalid rows skipped
* errors written to `error` column

---

## 🎉 CONCLUSION

This project now also includes **Bootstrap 5** for modern UI styling across layout, forms, tables, and action buttons.
This project demonstrates:

* Clean Rails architecture
* Secure Google API integration
* Bi-directional synchronization
* Maintainable and extendable codebase
