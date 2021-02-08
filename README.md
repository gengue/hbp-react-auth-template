# Hasura Backed Plus + React

This repo is a template for auth management in react applications using the [awesome hasura-backend-plus](https://github.com/nhost/hasura-backend-plus/)

## Features

The UI/UX is minimal, just plain html and JWT tokens are handled in the right way along with react-router

* Login with email/password
* Token is stored in memory to avoid CSFR & XSS 
* Persistent session using refresh token
* Route redirection handled
* Tab sync logout

## Get Started

Run the backend:

```
docker-compose up -d
```

Install frontend dependencies and run the development server:

```
cd client/
yarn start
```

## TODO

* ENV files setup
* Registration workflow
* Reset password
* 3rd party login (OAuth)
* Paswordless login
* multi factor authentication 
