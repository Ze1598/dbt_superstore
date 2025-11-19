import streamlit as st
import pandas as pd
from sqlalchemy import create_engine
import plotly.express as px
import plotly.graph_objects as go



def create_engine_connection():
    try:
        # Define connection URL in the format: 'postgresql+psycopg2://user:password@host/database'
        engine = create_engine("postgresql+psycopg2://analytics:analytics@localhost/superstore")
        print("PostgreSQL connection engine created")
        return engine
    except Exception as e:
        print("Error creating engine:", e)
        return None
    
def format_currency(value: int) -> str:
    num_digits = len(str(int(value)))
    if num_digits >= 9:
        divider = 1_000_000_000
        unit = "B"
    elif num_digits >= 6:
        divider = 1_000_000
        unit = "M"
    elif num_digits >= 3:
        divider = 1_000
        unit = "K"
    else:
        divider = 1
        unit = ""
    
    decimal_rep = value / divider
    return f"€ {decimal_rep:,.2f}{unit}"



engine = create_engine_connection()
if engine:
    ################################################################
    # Load from DB
    # st.success("PostgreSQL connection engine created successfully")
    query = "SELECT * FROM analytics_marts.fct_streamlit;"
    df = pd.read_sql(query, con=engine, parse_dates=["order_date"])

    ################################################################
    # Create a filter menu using the sidebar feature
    st.sidebar.header("Filter Menu")

    # Multi select to cherry pick years
    years_available = df.order_date.dt.year.unique().tolist()
    years_input = st.sidebar.multiselect(
        "Years for Analysis",
        options = years_available,
        default = years_available
    )
    # And a numeric input for the Top N visuals
    topn_input = st.sidebar.number_input("Top N States", min_value=1, value=5, step=1)
    topn_measure_input = st.sidebar.selectbox("Top N Measure", options=("state", "customer", "product"), placeholder="state", format_func=str.capitalize)

    ################################################################
    # KPI Sales
    total_sales = df["sales"].sum()
    total_profit = df["profit"].sum()
    return_rate = df['is_returned'].sum() / len(df)

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Sales", format_currency(total_sales), "23%")
    col2.metric("Total Profit", format_currency(total_profit), "20%")
    col3.metric("Return Rate", f"{return_rate:.2%}", "-4%", delta_color="inverse")

    ################################################################
    # Matrix of visuals
    col1, col2 = st.columns(2)

    # Revenue By Year
    with col1:
        df["order_year"] = df["order_date"].dt.year
        df = df[df.order_year.isin(years_input)]
        df_grouped = df.groupby("order_year").agg({"sales": "sum"}).reset_index()
        fig = px.line(df_grouped, x="order_year", y="sales", title="Revenue by Year", labels={"order_year": "Year", "sales":"Sales (€)"})
        fig.update_yaxes(range=[0, None])
        st.plotly_chart(fig)

    # Revenue By Month
    with col2:
        df["order_month"] = df.order_date.dt.to_period("M")
        df_grouped = df.groupby("order_month").agg({"sales": "sum"}).reset_index()
        df_grouped["order_month"] = df_grouped["order_month"].dt.to_timestamp()
        fig = px.line(df_grouped, x="order_month", y="sales", title="Revenue by Month", labels={"order_month": "Month Year", "sales":"Sales (€)"})
        fig.update_yaxes(range=[0, None])
        st.plotly_chart(fig)

    ################################################################
    # Other visuals
    # Top States By Revenue
    match topn_measure_input:
        case "state":
            topn_measure_column = "geography_state"
        case "customer":
            topn_measure_column = "customer_name"
        case "product":
            topn_measure_column = "product_category"
    topn_visual_title = f"{topn_measure_input.capitalize()}s"

    df_grouped = df.groupby(df[topn_measure_column]).agg({"sales": "sum"}).reset_index()
    df_grouped = df_grouped.sort_values(by="sales", ascending=False).head(n=topn_input)
    fig = px.bar(
        df_grouped, 
        x="sales", 
        y=topn_measure_column, 
        title=f"Top {topn_visual_title} by Revenue", 
        orientation="h", 
        labels={topn_measure_column: topn_measure_input.capitalize(), "sales":"Sales (€)"}
    )
    # Order states (Y axis) by the sales values (aka total)
    fig.update_yaxes(categoryorder='total ascending')
    st.plotly_chart(fig)

    ################################################################
    # Raw data display
    st.subheader("Raw Data")
    st.write(df)

    # Dispose the engine when done
    engine.dispose()