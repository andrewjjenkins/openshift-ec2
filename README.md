Want an OpenShift instance with more horsepower than your laptop?  This
CloudFormation template will quickly spin up an EC2 virtual machine and then
"oc cluster up" to create a 1-node OpenShift cluster.

To create the stack:

    git clone https://github.com/andrewjjenkins/minishift-ec2
    cd minishift-ec2
    STACKNAME=andrew-minishift-dev KEYNAME=andrews-ssh-key ./create-minishift.sh


`STACKNAME` is what you would like the cloudformation stack to be named.  This
stack will have all the resources (like the EC2 instance) inside of it, so you
should delete it when you're done.  Defaults to `\`whoami\`-minishift-dev`

`KEYNAME` is the name of an SSH keypair in AWS that you need to configure and
supply.  See [AWS
docs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
for more.  No default.  You can get a list of configured keypairs using `aws
ec2 describe-key-pairs`.

When done, output like this:

    {
      "StackId": "arn:aws:cloudformation:us-west-2:112345677999:stack/andrew-minishift-dev/64444444-2baa-1111-bbbb-dddddddddddd"
    }
    Stack created.
    Login with ssh command:
      ssh ubuntu@34.201.122.297
    Delete the stack when you're done with:
      aws cloudformation delete-stack --stack-name andrew-minishift-dev

# In the box

 - Default instance is an m4.2xlarge with 60GB EBS
 - Minishift and docker are installed and running
 - Kubernetes utils like kubectl, kubectx, kubens, stern, helm installed

# What now?

Use Openshift:

    $ ssh ubuntu@34.201.122.297
    $ oc get nodes
    NAME        STATUS    ROLES     AGE       VERSION
    localhost   Ready     <none>    4m        v1.11.0+d4cacc0
    $ kubectl get pods -n kube-system
    NAME                                READY     STATUS    RESTARTS   AGE
    kube-controller-manager-localhost   1/1       Running   0          4m
    kube-scheduler-localhost            1/1       Running   0          4m
    master-api-localhost                1/1       Running   0          3m
    master-etcd-localhost               1/1       Running   0          3m

# Stopping to save money

If you shutdown the instance, it will enter the EC2 stopped state but not
terminate.  While this is happening, you don't have to pay the EC2 instance
charges but you will still have to pay for the storage and Elastic IP.

    ssh ubuntu@34.201.122.297 "shutdown -h now"

Start back up:

    aws ec2 start-instances --instance-ids `aws cloudformation describe-stacks --stack-name andrew-minishift-dev | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="InstanceId") | .OutputValue'`

# Done

Remember to delete the stack when you're done so you don't accumulate charges:

    aws cloudformation delete-stack --stack-name andrew-minishift-dev
