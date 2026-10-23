# Fiche de Cadrage - Projet NovaSphere

* **Groupe 8 :** (on tourne sur les rôles Git et AWS).
* **Contexte métier :** NovaSphere est une startup SaaS. L'infrastructure que l'on gère héberge le site web de l'entreprise.
* **Extension choisie :** Configuration des serveurs par Ansible au démarrage par ansible-pull. Cela permet de garder le script de bootstrap sous la limite des 10 lignes exigée.
* **Extensions écartées :** 
  * Bastion SSH : rejeté car on veut réduire la surface d'attaque (aucun accès direct).
  * HTTPS : rejeté car on n'a pas de nom de domaine disponible via le Learner Lab.
