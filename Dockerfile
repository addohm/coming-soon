FROM nginx:1.27-alpine
COPY index.html /usr/share/nginx/html/index.html
COPY male_side.svg /usr/share/nginx/html/male_side.svg
COPY female_side.svg /usr/share/nginx/html/female_side.svg
EXPOSE 80
