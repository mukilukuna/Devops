from autots import AutoTS
from seaborn import regression
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
sns.set()
plt.style.use('seaborn-whitegrid')

data = pd.read_csv("Dogecoin.csv")
print("Shape of Dataset is: ", data.shape, "\n")
print(data.head())

data.dropna()
plt.figure(figsize=(10, 4))
plt.title("DogeCoin Price INR")
plt.xlabel("Date")
plt.ylabel("Close")
plt.plot(data["Close"])
plt.show()

model = AutoTS(forecast_length=10, frequency='infer',
               ensemble='simple', drop_data_older_than_periods=200)
model = model.fit(data, date_col='Date', value_col='Close', id_col=None)

prediction = model.predict()
forecast = prediction.forecast
print("DogeCoin Price Prediction")
print(forecast)
