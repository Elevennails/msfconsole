version: '3'

x-home-directory: &home-directory /home/simon

services:
  postgres:
    image: postgres:11-alpine
    networks:
      msf:
        aliases:
          - postgres
    volumes:
      - ${MSF_HOME}/.msf4/database:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_USER: postgres
      POSTGRES_DB: msf
      MSF_HOME: *home-directory

  msf:
    image: metasploitframework/metasploit-framework
    networks:
      msf:
        aliases:
          - msf
    volumes:
      - ${MSF_HOME}/.msf4:/home/msf/.msf4
    ports:
      - "8443-8500:8443-8500"
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/msf
      MSF_HOME: *home-directory
    deploy:
      restart_policy:
        condition: on-failure
        delay: 500s
        max_attempts: 3
    stdin_open: true
    tty: true
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  msf:
