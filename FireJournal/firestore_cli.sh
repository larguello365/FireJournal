# Replace with your actual data and URL
DATABASE_URL='https://firewatch-2025-default-rtdb.firebaseio.com/tasks.json'
TASK_DATA='{"taskName": "Grocery Shopping", "priority": "High", "dueDate": "2024-03-15"}'

#If your security rules require authentication
#AUTH_TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6ImE5ZGRjYTc2YzEyMzMyNmI5ZTJlODJkOGFjNDg0MWU1MzMyMmI3NmEiLCJ0eXAiOiJKV1QifQ.eyJwcm92aWRlcl9pZCI6ImFub255bW91cyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9maXJld2F0Y2gtMjAyNSIsImF1ZCI6ImZpcmV3YXRjaC0yMDI1IiwiYXV0aF90aW1lIjoxNzQzNjIyNDUxLCJ1c2VyX2lkIjoiU0JCeUJhclUxQk5Bb3JKQWVpTEVxT3ZVZVY1MiIsInN1YiI6IlNCQnlCYXJVMUJOQW9ySkFlaUxFcU92VWVWNTIiLCJpYXQiOjE3NDM2MjI0NTEsImV4cCI6MTc0MzYyNjA1MSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6e30sInNpZ25faW5fcHJvdmlkZXIiOiJhbm9ueW1vdXMifX0.C1FOjzYG1770LumdCpwgjolhfaL0Lr3ES0uoycAvL5na_RUcmgTsQ9zlk9TT3QHYv1Qg_3aXdbuEY3Q1SVb18u4VSA4mv2k4aTQls-zJ1euMHU6eJmQJs4NtW3S5nvYcDnVAz6iOGuV6-FD6Fo_t7TQgK7AiXM96R8Kx1u2lkFdMQZgDFYNer-yRYkDTz1ET8IEGfg4TsqihHQoOv7Z1FUkZzfiUPW4hWbsGX6cq8xNzLYuY1GvcJx8IMs9zKhaqofROLGaMfXOB9_scFxp73Ovq1xIzELJTSqsnUJbEvbTo8gra2XbhKoy_voLlSmG2LMwTn-axpYDiQMRuLXRxNg"
#curl -X POST -d "$TASK_DATA" "$DATABASE_URL?auth=$AUTH_TOKEN"

# If your database is public/unprotected (use with caution!)
#curl -X POST -d "$TASK_DATA" "$DATABASE_URL"


# Unique ID from RTDB
#{"name":"-OMrjp2SL4Tmfj5cDb1V"}

# Replace with your actual data and URL
DATABASE_URL='https://firewatch-2025-default-rtdb.firebaseio.com/SBByBarU1BNAorJAeiLEqOvUeV52/tasks.json'
TASK_DATA='{"taskName": "Grocery Shopping", "priority": "High", "dueDate": "2024-03-15"}'


#If your security rules require authentication
#AUTH_TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6ImE5ZGRjYTc2YzEyMzMyNmI5ZTJlODJkOGFjNDg0MWU1MzMyMmI3NmEiLCJ0eXAiOiJKV1QifQ.eyJwcm92aWRlcl9pZCI6ImFub255bW91cyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9maXJld2F0Y2gtMjAyNSIsImF1ZCI6ImZpcmV3YXRjaC0yMDI1IiwiYXV0aF90aW1lIjoxNzQzNjIyNDUxLCJ1c2VyX2lkIjoiU0JCeUJhclUxQk5Bb3JKQWVpTEVxT3ZVZVY1MiIsInN1YiI6IlNCQnlCYXJVMUJOQW9ySkFlaUxFcU92VWVWNTIiLCJpYXQiOjE3NDM2MjI0NTEsImV4cCI6MTc0MzYyNjA1MSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6e30sInNpZ25faW5fcHJvdmlkZXIiOiJhbm9ueW1vdXMifX0.C1FOjzYG1770LumdCpwgjolhfaL0Lr3ES0uoycAvL5na_RUcmgTsQ9zlk9TT3QHYv1Qg_3aXdbuEY3Q1SVb18u4VSA4mv2k4aTQls-zJ1euMHU6eJmQJs4NtW3S5nvYcDnVAz6iOGuV6-FD6Fo_t7TQgK7AiXM96R8Kx1u2lkFdMQZgDFYNer-yRYkDTz1ET8IEGfg4TsqihHQoOv7Z1FUkZzfiUPW4hWbsGX6cq8xNzLYuY1GvcJx8IMs9zKhaqofROLGaMfXOB9_scFxp73Ovq1xIzELJTSqsnUJbEvbTo8gra2XbhKoy_voLlSmG2LMwTn-axpYDiQMRuLXRxNg"
#curl -X POST -d "$TASK_DATA" "$DATABASE_URL?auth=$AUTH_TOKEN"

# If your database is public/unprotected (use with caution!)
curl -X POST -d "$TASK_DATA" "$DATABASE_URL"


# Unique ID from RTDB
#{"name":"-OMrjp2SL4Tmfj5cDb1V"}
