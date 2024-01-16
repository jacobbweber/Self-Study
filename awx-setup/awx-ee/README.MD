# awx_on_k3s
Must have docker installed to build the container
Must have ansible_builder installed

pip install ansible-builder

cd awx_execution_environment/builder

ansible-builder build --tag docker build -t example.repo.com:5050/teamgroup/awx_on_k3s:prod --container-runtime docker --verbosity 3

docker login example.repo.com:5050 -u username -p "git lab api access token"

docker push example.repo.com:5050/teamgroup/awx_on_k3s:prod
