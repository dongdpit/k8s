# k8s
FIX BUG coredns
-------------
kubectl edit cm coredns -n kube-system

rào dòng loop

Provisioning node using Terraform+Ansible
-------------
#Tạo SSH Key 

ssh-keygen -t rsa 

#Copy ssh-key cho kmaster đã có sẵn 

ssh-copy-id –i /root/.ssh/id_rsa.pub user@”IP kmaster” 

apt install -y sshpass 
![Untitled Diagram-terraform-ansible drawio](https://github.com/user-attachments/assets/b7b8cea3-8c6f-4a7c-a030-b14d1f817677)
