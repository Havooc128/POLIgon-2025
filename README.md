# POLIgon 2025

POLIgon 2025 is a full-stack Progressive Web Application created for participants of the **POLIgon training camp**.  
The app was developed for the **12th edition of the camp (2025)** to provide attendees with a centralized, real-time source of information during the event.

The project consists of a **Spring Boot backend** and a **Flutter mobile frontend**, communicating via REST API and WebSockets.

---

## Purpose of the Application

The application was designed to support participants during a multi-day training camp by providing:
- up-to-date schedules and training details
- real-time announcements from organizers
- access to teams, trainers and daily activities
- a clear and user-friendly mobile experience during the event

---

## Key Features
- Training camp schedule with session details
- Real-time announcements (WebSocket)
- Teams, trainers and crews overview
- Daily quests and activities
- Training paths and map view
- User authentication via Firebase
- Offline mode
- Progressive Web App

---

## Tech Stack

### Backend
- Java 17
- Spring Boot
- Spring Security
- Spring Data JPA
- Firebase Authentication
- WebSocket
- REST API

### Frontend
- Flutter
- Provider (state management)
- Dio (HTTP client)
- WebSocket integration

---

## Architecture Overview

### Backend
- **Controllers** – REST endpoints for core domains (schedule, announcements, teams, trainers, quests)
- **Models & Repositories** – database entities and persistence layer
- **Security** – Firebase authentication filter and CORS configuration
- **WebSocket** – real-time communication with mobile clients

### Frontend
- **Screens** – UI views for individual features
- **Providers** – state management and data flow
- **Services** – REST API, authentication and WebSocket handling
- **Models** – domain objects mapped from backend responses

## Authentication
The application uses Firebase Authentication.
A valid Firebase project and configuration are required to run the application locally.

---
