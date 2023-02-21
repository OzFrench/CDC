#
#    NOEUD WEBSPHERE PAR DEFAULT
#

set fullNodeName "/Node:$nodeName/"

#
#    VIRTUAL HOST
#


# Ici on pourra ajouter d'autres types d'attributs 
# par exemple une MIMETABLE

 
# Listes des Attributs du Virtual Host
set aliasattr [list AliasList $aliaslist]

set VHattributelist [list $aliasattr]

#
#    SERVER GROUP
#



# Variables pour faciliter la livraison avec des clones
set asName $sgName
set fullAsName "/ServerGroup:$asName/"

# Liste des parametres de la categorie EJBServerAttributes

# Configuration de la JVM du ServerGroup

set heapattr [list $minheapattr $maxheapattr]
set jvmconfigattr [list JVMConfig $heapattr]

# on ajoutera ici tous les autres parametres a customizer 
# Les 3 lignes suivantes ont ete ajoutees par simon pour la prise en compte du timeout
# du gestionnaire de sessions
#set timeoutattr [list $timeout]

#Ajout Simon pour la prise en compte du CookieSecure pour l'application AO
#set cookieattr [list $cookiesecure]

#Ajout Simon pour la prise en compte du CookieSecure pour l'application AO
set sessionattrbis [list $cookiesecure $timeout]

#Ajout Simon pour la prise en compte du CookieSecure pour l'application AO
set sessionattr [list SessionManagerConfig $sessionattrbis]

#Mise en commentaire Simon pour la prise en compte du CookieSecure pour l'application AO
#set sessionattr [list SessionManagerConfig $cookieattr $timeoutattr]

set webattr [list WebContainerConfig $sessionattr]

# Rapatriement de tous les parametres EJBServerAttributes
set ejbattributes [list EJBServerAttributes $userid $groupid $jvmconfigattr $webattr]

# Liste des attributs du ServerGroup
set SGattributelist [list $ejbattributes]


#
# ENTREPRISE APPLICATION
#


# Association du module War avec le VirtualHost
set modvirthost1 [list $warName1 $vhName]
set modvirthosts [list $modvirthost1]

#
# JDBC DRIVER
#

# Variables parametrables

# Ici on cree des listes pour installer le driver un ou plusieurs noeud WAS
# A noter que l'ordre des items est important et ainsi a chaque noeud doit correspondre le bon fichier


# Constitution des attributs
set DriverAttributelist [list $implClass $driverDescription]

#
# DATASOURCES
#



# Constitution des Attributs

set DSConfiglist [list]

for {set i 0} {$i < [llength $dataSourceName]} {incr i} {

   set tempconfig [list]

   for {set j 0} {$j < [llength $dataSourceName]} {incr j} {
      set templist [list [lindex $dbName $j] [lindex $ServerName $j] [lindex $PortNumber $j] [lindex $dbUser $j] [lindex $dbPasswd $j] [lindex $SqlInit $j] [lindex $Rep_Read $j] [lindex $Charset_Conv $j] [lindex $Dyna_Prep $j]]
      lappend tempconfig $templist
   }

   set templist [list ConfigProperties [lindex $tempconfig $i]]

   lappend DSConfiglist $templist
}

set DSattributelist [list]

for {set i 0} {$i < [llength $dataSourceName]} {incr i} {

   set templist [list [lindex $DSConfiglist $i] [lindex $dsDescription $i] [lindex $minPoolSize $i] [lindex $maxPoolSize $i] [lindex $connTimeout $i] [lindex $idleTimeout $i] [lindex $orphanTimeout $i] [lindex $statementCacheSize $i]]

   lappend DSattributelist $templist
}
