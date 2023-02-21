#
#
#  Example de fichier de variables WSCP pour WAS 4.x
#
#  Cet exemple utilise le ServerGroup et WLM
#

#
#    NOEUD WEBSPHERE PAR DEFAULT
#
set nodeName fsdevelop2
set fullNodeName "/Node:$nodeName/"


#
#    VIRTUAL HOST
#

# Nom du Virtual Host
set vhName default_host
 
# Liste des Alias
set aliaslist [list *:9084 *:10080 *:9080]

# Ici on pourra ajouter d'autres types d'attributs 
# par exemple une MIMETABLE

 
# Listes des Attributs du Virtual Host
set aliasattr [list AliasList $aliaslist]

set VHattributelist [list $aliasattr]


#
#    SERVER GROUP
#

# Nom du ServerGroup 
set sgName "testServerGroup"

# Variables pour faciliter la livraison avec des clones
set asName sgName
set fullAsName "/ServerGroup:$asName/"

# Liste des parametres de la categorie EJBServerAttributes

# Configuration de la JVM du ServerGroup
set minheapattr [list InitialHeapSize 32]
set maxheapattr [list MaxHeapSize 64]
set heapattr [list $minheapattr $maxheapattr]
set jvmconfigattr [list JVMConfig $heapattr]

# on ajoutera ici tous les autres parametres a customizer 

# Rapatriement de tous les parametres EJBServerAttributes
set ejbattributes [list EJBServerAttributes $jvmconfigattr]

# Liste des attributs du ServerGroup
set SGattributelist [list $ejbattributes]


#
# CLONES (APPLICATION SERVER)
#

# Nombre de clones a installer
set NumberOfClones 2

# Noms des clones
set clone(name1) "CloneApplicationServer1"
set clone(fullName1) [list Name $clone(name1)]

set clone(name2) "CloneApplicationServer2"
set clone(fullName2) [list Name $clone(name2)]

# Noeuds ou tournent les clones
set clone(node1) "fsdevelop2"
set clone(node2) "fsmiami"


# fichier de sortie standard
set clone(Out1) "/fsdevelop2/product/was4/livraison/test_ServerGroup_stdout"
set clone(stdout1) [list Stdout $clone(Out1)]

set clone(Out2) "/fsmiami/product/websphere/v4.0.2/livraison/test_ServerGoup_stdout"
set clone(stdout2) [list Stdout $clone(Out2)]

# Fichier de sortie d'erreur
set clone(Err1) "/fsdevelop2/product/was4/livraison/test_ServerGroup_stderr"
set clone(stderr1) [list Stderr $clone(Err1)]

set clone(Err2) "/fsmiami/product/websphere/v4.0.2/livraison/test_ServerGroup_stderr"
set clone(stderr2) [list Stderr $clone(Err2)]


# Parametres du Plugin HTTP si on veut le configurer dans le AS ou 
# le clone sinon le port est genere automatiquement a la creation
#
# Port d'ecoute
#set portattr [list Port 9084]
#set httptransattr [list $portattr]
#set transportattr [list Transports $httptransattr]

#set webcontainerattr [list WebContainerConfig $transportattr]

# Liste des attributs du clone
set clone(CloneAttributelist1) [list $clone(stdout1) $clone(stderr1) $clone(fullName1)]
set clone(CloneAttributelist2) [list $clone(stdout2) $clone(stderr2) $clone(fullName2)]


#
# ENTREPRISE APPLICATION
#

# Nom et chemin du fichier EAR
set earName "/fsdevelop2/product/was4/livraison/socleSample.ear"

# Nom de l'EnterpriseApp
set eaName "SocleTechniqueSampleEAR"

# Nom du ou des modules WAR
set warName1 "SocleTechniqueSample.war"

# Association du module War avec le VirtualHost
set modvirthost1 [list $warName1 $vhName]
set modvirthosts [list $modvirthost1]



#
# JDBC DRIVER
#

# Variables parametrables

set jdbcDriverName TestSybaseDriver
set implClass [list ImplClass com.sybase.jdbc2.jdbc.SybConnectionPoolDataSource]
set driverDescription [list Description {TEST JDBC Driver}]

# Ici on cree des listes pour installer le driver un ou plusieurs noeud WAS
# A noter que l'ordre des items est important et ainsi a chaque noeud doit correspondre le bon fichier

set nodeInstalled [list fsdevelop2 fsmiami]
set jdbcZipfileLocation [list /fsdevelop2/product/sybase/dev/12.0/jConnect-5_2/classes/jconn2.jar /fsmiami/product/sybase/rec/12.0/jConnect-5_2/classes/jconn2.jar]

# Constitution des attributs
set DriverAttributelist [list $implClass $driverDescription]



#
# DATASOURCES
#

# Variables parametrables (exemple avec 2 datasources)

set dataSourceName [list TestDataSource1 TestDataSource2]

set dbName [list {databaseName TestDataBase1} {databaseName TestDataBase2}]
set ServerName [list {serverName fsdevelop2} {serverName fsmiami}]
set dbUser [list {user test1} {user test2}]
set dbPasswd [list {password test1} {password test2}]
set PortNumber [list {portNumber 6969} {portNumber 9696}]
set jndiName [list {JNDIName jdbc/TestDataSource1} {JNDIName jdbc/TestDataSource2}]
set dsDescription [list {Description {DataSource1 created by wscp}} {Description {DataSource2 created by wscp}}]
set minPoolSize [list {MinPoolSize 3} {MinPoolSize 2}]
set maxPoolSize [list {MaxPoolSize 20} {MaxPoolSize 19}]
set connTimeout [list {ConnTimeout 180} {ConnTimeout 181}]
set idleTimeout [list {IdleTimeout 1800} {IdleTimeout 1801}]
set orphanTimeout [list {OrphanTimeout 1800} {OrphanTimeout 1801}]
set statementCacheSize [list {StatementCacheSize 500} {StatementCacheSize 500}]


# Constitution des Attributs

set DSConfiglist [list]

for {set i 0} {$i < [llength $dataSourceName]} {incr i} {

   set tempconfig [list]

   for {set j 0} {$j < [llength $dataSourceName]} {incr j} {
      set templist [list [lindex $dbName $j] [lindex $ServerName $j] [lindex $PortNumber $j] [lindex $dbUser $j] [lindex $dbPasswd $j]]
      lappend tempconfig $templist
   }

   set templist [list ConfigProperties [lindex $tempconfig $i]]

   lappend DSConfiglist $templist
}

set DSattributelist [list]

for {set i 0} {$i < [llength $dataSourceName]} {incr i} {

   set templist [list [lindex $DSConfiglist $i] [lindex $jndiName $i] [lindex $dsDescription $i] [lindex $minPoolSize $i] [lindex $maxPoolSize $i] [lindex $connTimeout $i] [lindex $idleTimeout $i] [lindex $orphanTimeout $i] [lindex $statementCacheSize $i]]

   lappend DSattributelist $templist
}






# Message envoye a la fin
puts "\nImportation du Fichier de Variables terminee\n"
