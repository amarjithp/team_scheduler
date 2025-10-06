# 🗓️ Team Scheduler – Auto Slot Finder  

A realtime collaborative **Team Scheduler** built with **Flutter** and **Supabase**.  
Users can register with name & photo, set their availability, and create tasks with collaborators.  
The system automatically finds and displays **common available time slots** based on team members’ availability and task duration.  

🚀 Live Demo: [Team Scheduler Web App](https://team-scheduler-slot-finder.netlify.app/)  
📦 Repo: [GitHub Repository](https://github.com/amarjithp/team_scheduler)  

---

## ✨ Features  
- 👤 User onboarding with name & profile photo  
- 🕒 Add and manage availability slots  
- 📋 Create tasks with:  
  - Title & description  
  - Collaborator selection  
  - Duration (10 / 15 / 30 / 60 mins)  
  - Suggested time slots  
- 🤝 Automatic common slot finder for collaborators  
- ❌ “No available slots” message when conflicts exist  
- 🌐 Works on **Web, Android, and iOS**  

---

## 🛠️ Tech Stack  
- **Framework**: Flutter  
- **State Management**: BLoC / Cubit  
- **Backend**: Supabase (auth, database, storage)  
- **Deployment**: Netlify (Flutter Web)  

---

## ▶️ Getting Started  

### Clone & Run  
```bash
# Clone repo
git clone https://github.com/amarjithp/team_scheduler.git
cd team_scheduler

# Install packages
flutter pub get

# Run on web
flutter run -d chrome

```

## ⚠️ Important  
Before running the app, you’ll need to configure a **Supabase project** with the same schema used here.  

1. Create a new Supabase project.  
2. Apply the provided schema (tables: `users`, `availability`, `tasks`, `task_collaborators`).  
3. Add your **Supabase URL** and **Anon Key** into a `.env` file at the root of the project.  
4. The app will read these values during runtime.  

👉 I’ll update this README soon with detailed setup steps and example `.env` configuration.  

---

## 👨‍💻 Author  
**Amarjith P**  
- 🌐 [GitHub](https://github.com/amarjithp)  
