#!/bin/bash

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function getOutputsFromNetworkStack {
	eval $(aws cloudformation describe-stacks --stack-name proarchtraining-lab1-network --output text | grep OUTPUTS | \
			awk 'BEGIN{FS="[ \t,]"}; \
				{if ($4=="VpcId") \
					{print "export VpcId="$5} \
				else if ($5=="PublicSubnetIds") \
					{print "export PubASubnetId="$6"\nexport PubBSubnetId="$7} \
				else if ($6=="PrivateRouteTableId") \
					{print "export PrivateRouteTableId="$7} \
				}')
}

KeyName=proarchtraining_sebastiankrueger

DBName=wordpress
DBUsername=admin
DBPassword=wordpress

case $1 in 
	create-network)
		aws cloudformation create-stack \
			--stack-name proarchtraining-lab1-network \
			--template-body "file://${DIR}/basicvpc-seb.template.json"
	;;
	update-network)
		aws cloudformation update-stack \
			--stack-name proarchtraining-lab1-network \
			--template-body "file://${DIR}/basicvpc-seb.template.json"
	;;
	create-bastion-nat)

		getOutputsFromNetworkStack

		aws cloudformation create-stack \
			--stack-name proarchtraining-lab1-bastion-nat \
			--template-body "file://${DIR}/bastion-nat-seb.template.json" \
			--parameters \
				ParameterKey=KeyName,ParameterValue=${KeyName} \
				ParameterKey=VpcId,ParameterValue=${VpcId} \
				ParameterKey=PubASubnetId,ParameterValue=${PubASubnetId} \
				ParameterKey=PubBSubnetId,ParameterValue=${PubBSubnetId} \
				ParameterKey=PrivateRouteTableId,ParameterValue=${PrivateRouteTableId}
	;;
	update-bastion-nat)
		
		getOutputsFromNetworkStack

		aws cloudformation update-stack \
			--stack-name proarchtraining-lab1-bastion-nat \
			--template-body "file://${DIR}/bastion-nat-seb.template.json" \
			--parameters \
				ParameterKey=KeyName,ParameterValue=${KeyName} \
				ParameterKey=VpcId,ParameterValue=${VpcId} \
				ParameterKey=PubASubnetId,ParameterValue=${PubASubnetId} \
				ParameterKey=PubBSubnetId,ParameterValue=${PubBSubnetId} \
				ParameterKey=PrivateRouteTableId,ParameterValue=${PrivateRouteTableId}
	;;
	create-elb)

		getOutputsFromNetworkStack

		aws cloudformation create-stack \
			--stack-name proarchtraining-lab1-elb \
			--template-body "file://${DIR}/elb-seb.template.json" \
			--parameters \
				ParameterKey=VpcId,ParameterValue=${VpcId} \
				ParameterKey=PubASubnetId,ParameterValue=${PubASubnetId} \
				ParameterKey=PubBSubnetId,ParameterValue=${PubBSubnetId}
	;;
	update-elb)
		
		getOutputsFromNetworkStack

		aws cloudformation update-stack \
			--stack-name proarchtraining-lab1-elb \
			--template-body "file://${DIR}/elb-seb.template.json" \
			--parameters \
				ParameterKey=VpcId,ParameterValue=${VpcId} \
				ParameterKey=PubASubnetId,ParameterValue=${PubASubnetId} \
				ParameterKey=PubBSubnetId,ParameterValue=${PubBSubnetId}
	;;
	create-rds)

		getOutputsFromNetworkStack

		aws cloudformation create-stack \
			--stack-name proarchtraining-lab1-rds \
			--template-body "file://${DIR}/rds-seb.template.json" \
			--parameters \
				ParameterKey=VpcId,ParameterValue=${VpcId} \
				ParameterKey=PubASubnetId,ParameterValue=${PubASubnetId} \
				ParameterKey=PubBSubnetId,ParameterValue=${PubBSubnetId} \
				ParameterKey=DBName,ParameterValue=${DBName} \
				ParameterKey=DBUsername,ParameterValue=${DBUsername} \
				ParameterKey=DBPassword,ParameterValue=${DBPassword}
	;;
	update-rds)
		
		getOutputsFromNetworkStack

		aws cloudformation update-stack \
			--stack-name proarchtraining-lab1-rds \
			--template-body "file://${DIR}/rds-seb.template.json" \
			--parameters \
				ParameterKey=VpcId,ParameterValue=${VpcId} \
				ParameterKey=PubASubnetId,ParameterValue=${PubASubnetId} \
				ParameterKey=PubBSubnetId,ParameterValue=${PubBSubnetId} \
				ParameterKey=DBName,ParameterValue=${DBName} \
				ParameterKey=DBUsername,ParameterValue=${DBUsername} \
				ParameterKey=DBPassword,ParameterValue=${DBPassword}
	;;
	*)
        echo $"Usage: $0 {[create|update]-[network|bastion-nat|elb|rds]}"
        exit 1
esac
