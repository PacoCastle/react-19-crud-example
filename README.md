# React 19 CRUD Example 🚀

A complete **React 19.1.1** application showcasing modern React development with full CRUD operations, Docker containerization, and Google Cloud Platform deployment.

## 🌟 Features

- **React 19.1.1** - Latest React version with cutting-edge features
- **Modern Architecture** - Functional components with hooks
- **Docker Support** - Multi-stage builds for production optimization
- **GCP Deployment** - App Engine, Cloud Run, and Kubernetes ready
- **Production Ready** - Nginx configuration with security headers
- **Comprehensive Documentation** - Complete guides for all aspects

## 🚀 Live Demo

- **Production**: [https://react-19-crud-example-467321.uc.r.appspot.com](https://react-19-crud-example-467321.uc.r.appspot.com)
- **Local Docker**: `http://localhost:8080` (or auto-detected port)

## 📋 Prerequisites

- **Node.js 20+**
- **Docker** (for containerization)
- **Google Cloud CLI** (for GCP deployment)

## 🛠️ Quick Start

### Local Development
```bash
# Clone the repository
git clone https://github.com/PacoCastle/react-19-crud-example.git
cd react-19-crud-example

# Install dependencies
npm install

# Start development server
npm start
```

### Docker Deployment
```bash
# Build and run with automatic port conflict resolution
./deploy-docker.ps1

# Manual Docker build
docker build -t react-19-crud .
docker run -p 8080:8080 react-19-crud
```

### Google Cloud Platform
```bash
# Deploy to App Engine
gcloud app deploy

# Deploy to Cloud Run
gcloud run deploy react-19-crud --source .

# Deploy to Kubernetes
kubectl apply -f k8s/
```

### `npm run build`

Builds the app for production to the `build` folder.\
It correctly bundles React in production mode and optimizes the build for the best performance.

The build is minified and the filenames include the hashes.\
Your app is ready to be deployed!

See the section about [deployment](https://facebook.github.io/create-react-app/docs/deployment) for more information.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can't go back!**

If you aren't satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

Instead, it will copy all the configuration files and the transitive dependencies (webpack, Babel, ESLint, etc) right into your project so you have full control over them. All of the commands except `eject` will still work, but they will point to the copied scripts so you can tweak them. At this point you're on your own.

You don't have to ever use `eject`. The curated feature set is suitable for small and middle deployments, and you shouldn't feel obligated to use this feature. However we understand that this tool wouldn't be useful if you couldn't customize it when you are ready for it.

## Learn More

You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).

To learn React, check out the [React documentation](https://reactjs.org/).

### Code Splitting

This section has moved here: [https://facebook.github.io/create-react-app/docs/code-splitting](https://facebook.github.io/create-react-app/docs/code-splitting)

### Analyzing the Bundle Size

This section has moved here: [https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size](https://facebook.github.io/create-react-app/docs/analyzing-the-bundle-size)

### Making a Progressive Web App

This section has moved here: [https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app](https://facebook.github.io/create-react-app/docs/making-a-progressive-web-app)

### Advanced Configuration

This section has moved here: [https://facebook.github.io/create-react-app/docs/advanced-configuration](https://facebook.github.io/create-react-app/docs/advanced-configuration)

### Deployment

This section has moved here: [https://facebook.github.io/create-react-app/docs/deployment](https://facebook.github.io/create-react-app/docs/deployment)

### `npm run build` fails to minify

This section has moved here: [https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify](https://facebook.github.io/create-react-app/docs/troubleshooting#npm-run-build-fails-to-minify)
