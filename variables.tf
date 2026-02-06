variable "aws_region" {
    description = "This is the value where resion assign"
    type = string
}
variable "aws_instance_type" {
    description =  "This is the AWS instance type"
    type = string

}
variable "aws_ami" {
    description = "This is the AWS AMI ID"
    type = string
}
variable "aws_key_name" {
    description = "Key for accessing instance"
    type = string
}
variable "public_key_path" {
    description = "Path to public key SSH"
    type = string
}
variable "root_volume_size" {
    description = "assigning value storage of instance"
    type = number
}