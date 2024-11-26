# Flutter App: Farmer Crop Management and Invoice Generator

## Overview

This Flutter application is designed to help farmers manage their crop details and calculate the total cost based on drone usage for applying Parijat products. The app allows users to input farmer details, track multiple crops, and generate a PDF invoice with all the necessary details.

## Features

- **Farmer Information Entry**: Input fields for farmer name, mobile number, and address.
- **Crop Details Entry**: Dynamically add multiple crops with details such as crop name, total acreage, drone usage acreage, selected Parijat product, and quantity used.
- **Drone Usage Calculation**: Automatically sum up the total drone usage acreage across all crops.
- **Cost Calculation and Invoice Generation**: Input the per-acre charge for drone usage, calculate the total amount, and generate a PDF invoice with all details.

## Technologies Used
- **Flutter**: Used to Develop the App
- **Flask**: Used to work as Api for both Flutter App and Mysql.
- **Mysql**: Used to store the data.

## Screenshots

# Farmer Information Entry:
![scrcpy_QLGxC6RzWs](https://github.com/user-attachments/assets/2e034828-8fef-4283-83d2-07afeeec8090)
# Crop Details Entry:
![scrcpy_ialm4B9ec1](https://github.com/user-attachments/assets/f996cc05-14ba-42ad-8081-2e7973081f30)
# Invoice Page:
![chrome_UdCl6n9cp3](https://github.com/user-attachments/assets/499a6280-edfd-4c51-8c0d-970d9c17e882)

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/likhith1409/Farmers_App.git
cd farmer-crop-management
```
### 2. Install Flutter Dependencies

```bash
flutter pub get
```
### 3. Run the Flask Server

```bash
python details_api.py
```
### 4. Run the Flutter App
```bash
flutter run
```


