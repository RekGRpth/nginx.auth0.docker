1) create file `.env` with contents
```env
AUTH0_CLIENT_ID=YOUR_AUTH0_CLIENT_ID
AUTH0_CLIENT_SECRET=YOUR_AUTH0_CLIENT_SECRET
AUTH0_DOMAIN=YOUR_AUTH0_DOMAIN
NGINX_SERVER_NAME=YOUR_NGINX_SERVER_NAME
```
2) put your cert and key into files `cert.pem` and `key.pem`
3) run
```sh
docker-compose up
```
