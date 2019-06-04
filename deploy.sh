
#
# This script will be executed by travis in "deploy" phase.
# No need to login to docker again since we already logged in to docker in .travis.yml
#

#
# By default, the tag will be "latest"
# This means every time we build a new image, the tag would be "latest"
# Since the tag is not changing, kubectl thinks nothing has changed
# Hence, no images will be updated in our pods
# Bottom line, we'll need to tag our images uniqyely for each build
# That said, we'll still create a "latest" tag since all our *-deployment.yml use image names without tags
# So the latest tag will be pulled. Also, it helps when a new person applies the k8s configs.
# He/she won't have to worry about which sha to use.
# So, both "latest" and "sha" will exactly be the same images
#
docker build -t vaibhavdesai137/kubernetes-workflow-workerapp:latest -f ./worker-app/Dockerfile.prod ./worker-app
docker build -t vaibhavdesai137/kubernetes-workflow-workerapp:$GIT_SHA -f ./worker-app/Dockerfile.prod ./worker-app

docker build -t vaibhavdesai137/kubernetes-workflow-apiapp:latest -f ./api-app/Dockerfile.prod ./api-app
docker build -t vaibhavdesai137/kubernetes-workflow-apiapp:$GIT_SHA -f ./api-app/Dockerfile.prod ./api-app

docker build -t vaibhavdesai137/kubernetes-workflow-webapp:latest -f ./web-app/Dockerfile.prod ./web-app
docker build -t vaibhavdesai137/kubernetes-workflow-webapp:$GIT_SHA -f ./web-app/Dockerfile.prod ./web-app

# Push to docker
docker push vaibhavdesai137/kubernetes-workflow-workerapp:latest
docker push vaibhavdesai137/kubernetes-workflow-workerapp:$GIT_SHA

docker push vaibhavdesai137/kubernetes-workflow-apiapp:latest
docker push vaibhavdesai137/kubernetes-workflow-apiapp:$GIT_SHA

docker push vaibhavdesai137/kubernetes-workflow-webapp:latest
docker push vaibhavdesai137/kubernetes-workflow-webapp:$GIT_SHA

# Apply k8s configs
kubectl apply -f k8s

# Set images to use for each deployment so kubectl knows its needs to update the image in the pods
# Without this step, new image will be available in dockerhub but kubectl won't knonw about it
kubectl set image deployments/apiapp-deployment workerapp-container=vaibhavdesai137/kubernetes-workflow-workerapp:$GIT_SHA
kubectl set image deployments/apiapp-deployment apiapp-container=vaibhavdesai137/kubernetes-workflow-apiapp:$GIT_SHA
kubectl set image deployments/apiapp-deployment webapp-container=vaibhavdesai137/kubernetes-workflow-webapp:$GIT_SHA
