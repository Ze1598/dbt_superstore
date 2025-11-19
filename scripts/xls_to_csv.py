"""
Implement this script to convert an Excel file to CSV format.
This script should take an Excel file as input and output a CSV file.
"""

import pandas as pd
import os

data = "data/Sample - Superstore.xls"
out_path_base = os.path.join(os.getcwd(), "dbt_superstore", "seeds")

orders_df = pd.read_excel(data, sheet_name="Orders")
out_path_orders = os.path.join(out_path_base, "orders.csv")
orders_df.to_csv(out_path_orders, index=False)

returns_df = pd.read_excel(data, sheet_name="Returns")
out_path_returns = os.path.join(out_path_base, "returns.csv")
returns_df.to_csv(out_path_returns, index=False)