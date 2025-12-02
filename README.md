# Expense Tracker Flutter App

A Flutter-based Expense Tracker application with **Firebase backend** for Authentication and Firestore Cloud Database.  
This project uses models, services, and Firebase integration to handle users, budgets, and transactions.

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Firebase Backend](#firebase-backend)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Firestore Security Rules](#firestore-security-rules)
- [Contributing](#contributing)
- [License](#license)

---

## Features

- User registration, login, and profile management
- Budget planning and allocation (needs, wants, savings)
- Add, edit, delete income and expense transactions
- Stream and filter transactions by date and category
- Firebase Authentication and Firestore integration
- Backend-ready with models and services (UserModel, BudgetModel, TransactionModel)
- Null-safe Firestore CRUD operations

---

## Prerequisites

- Flutter SDK (>=3.0.0)  
- Dart SDK  
- Firebase Project with:
  - Firebase Authentication (Email/Password) enabled
  - Firestore Database enabled
  - Optional: Firebase Storage and FCM for future features

---

## Setup

1. **Clone the repository**

```bash
git clone https://github.com/<your-repo>/expense_tracker.git
cd expense_tracker

**Install dependencies**
```bash
flutter pub get

**Firebase configuration**
Since firebase_options.dart is included, the project is already linked to the Firebase project.
Make sure you have access to the Firebase project (added as Editor in Firebase console).

**Run the app**
flutter run
