# Dans le cadre du Learner Lab AWS Academy, on utilise le LabRole pré-existant
# au lieu de créer un rôle (ce qui est interdit par les politiques du lab).

data "aws_iam_instance_profile" "lab" {
  name = "LabInstanceProfile"
}
