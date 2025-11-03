FROM ubuntu:24.10 AS builder

# Installation de Node.js et npm
RUN apt-get update && \
    apt-get install -y curl ca-certificates gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Création du répertoire de travail
WORKDIR /source

# Copie du code source
COPY . .

# Installation des dépendances en production
RUN npm ci --only=production

# Build de l'application si nécessaire
RUN npm run build --if-present

FROM ubuntu:24.10 AS prod

# Installation minimale de Node.js pour exécuter l’application
RUN apt-get update && \
    apt-get install -y curl ca-certificates gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Définition du répertoire de travail
WORKDIR /app

# Copie depuis l’image de build
COPY --from=builder /source /app

# Exposition du port de Juice Shop (par défaut 3000)
EXPOSE 3000

# Variables d’environnement par défaut
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# Lancement de l’application
ENTRYPOINT ["npm", "start"]
