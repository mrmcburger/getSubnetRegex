getSubnetRegex
==============

The goal of this function is to return an array with regex(s) to match every ip address in a subnet.
# Param 1 : subnet (ex 10.0.0.0)
# Param 2 : mast (ex 255.0.0.0)
# To achieve this we match /32, /24, /16 et /8 subnets. 
# Example with 192.168.0.0/23, we are getting an array with 2 entries :
#$VAR1 = [
#      '192\\.168\\.0\\.[0-9]{1,3}',
#      '192\\.168\\.1\\.[0-9]{1,3}'
#    ];
