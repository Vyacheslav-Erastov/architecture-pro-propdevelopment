kubectl run front-end-app --image=nginx --labels=role=front-end --expose --port=80
kubectl run back-end-api-app --image=nginx --labels=role=back-end-api --expose --port=80  
kubectl run admin-front-end-app --image=nginx --labels=role=admin-front-end --expose --port=80
kubectl run admin-back-end-api-app --image=nginx --labels=role=admin-back-end-api --expose --port=80

kubectl apply -f non-admin-api-allow.yaml

kubectl get netpol
kubectl get pods --show-labels

kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh / # wget -qO- --timeout=2 http://back-end-api-app