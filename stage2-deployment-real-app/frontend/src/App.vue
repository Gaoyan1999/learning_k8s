<template>
  <div class="app">
    <header>
      <h1>User Management System</h1>
    </header>
    <main>
      <div class="form-section">
        <h2>Add New User</h2>
        <form @submit.prevent="createUser">
          <input v-model="newUser.name" type="text" placeholder="Name" required />
          <input v-model="newUser.email" type="email" placeholder="Email" required />
          <button type="submit">Add User</button>
        </form>
      </div>
      <div class="users-section">
        <h2>Users List</h2>
        <div v-if="loading">Loading...</div>
        <div v-else-if="error" class="error">{{ error }}</div>
        <ul v-else class="users-list">
          <li v-for="user in users" :key="user.id" class="user-item">
            <div class="user-info">
              <strong>{{ user.name }}</strong>
              <span>{{ user.email }}</span>
            </div>
            <div class="user-actions">
              <button @click="deleteUser(user.id)" class="delete-btn">Delete</button>
            </div>
          </li>
        </ul>
      </div>
    </main>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'App',
  data() {
    return {
      users: [],
      loading: false,
      error: null,
      newUser: {
        name: '',
        email: ''
      }
    }
  },
  mounted() {
    this.fetchUsers()
  },
  methods: {
    async fetchUsers() {
      this.loading = true
      this.error = null
      try {
        const response = await axios.get('/api/users')
        this.users = response.data
      } catch (err) {
        this.error = 'Failed to fetch users: ' + err.message
        console.error(err)
      } finally {
        this.loading = false
      }
    },
    async createUser() {
      try {
        await axios.post('/api/users', this.newUser)
        this.newUser = { name: '', email: '' }
        this.fetchUsers()
      } catch (err) {
        this.error = 'Failed to create user: ' + err.message
        console.error(err)
      }
    },
    async deleteUser(id) {
      try {
        await axios.delete(`/api/users/${id}`)
        this.fetchUsers()
      } catch (err) {
        this.error = 'Failed to delete user: ' + err.message
        console.error(err)
      }
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  background: #f5f5f5;
}

.app {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

header {
  background: #2c3e50;
  color: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  text-align: center;
}

h1 {
  font-size: 24px;
}

main {
  display: grid;
  gap: 20px;
}

.form-section, .users-section {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

h2 {
  margin-bottom: 15px;
  color: #2c3e50;
}

form {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

input {
  flex: 1;
  min-width: 200px;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

button {
  padding: 10px 20px;
  background: #3498db;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.3s;
}

button:hover {
  background: #2980b9;
}

.delete-btn {
  background: #e74c3c;
  padding: 5px 15px;
  font-size: 12px;
}

.delete-btn:hover {
  background: #c0392b;
}

.users-list {
  list-style: none;
}

.user-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #eee;
}

.user-item:last-child {
  border-bottom: none;
}

.user-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.user-info strong {
  color: #2c3e50;
}

.user-info span {
  color: #7f8c8d;
  font-size: 14px;
}

.error {
  color: #e74c3c;
  padding: 10px;
  background: #ffe6e6;
  border-radius: 4px;
  margin: 10px 0;
}
</style>

