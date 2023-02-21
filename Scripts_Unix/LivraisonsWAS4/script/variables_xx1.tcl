#
# CLONE XX
#


# Nom du clone
set clone(name1) [list "CloneApplicationServerXX"]

# Noeud ou tourne le clone
set clone(node1) [list "fsdevelop2"]

# fichier de sortie standard
set clone(Out1) [list "/fsdevelop2/dev/was4test/integration/test_XX_stdout"]

# Fichier de sortie d'erreur
set clone(Err1) [list "/fsdevelop2/dev/was4test/integration/test_XX_stderr"]

# TraceSpec
set clone(TraceSpec1) [list "fr.*=all=enabled"]

# Parametres du Plugin HTTP si on veut le configurer dans le AS ou
# le clone sinon le port est genere automatiquement a la creation
#
# Port d'ecoute
set clone(portattr1) [list Port 10055]
#
# CLONE
#


set clone(fullName1) [list Name $clone(name1)]



set clone(stdout1) [list Stdout $clone(Out1)]

set clone(stderr1) [list Stderr $clone(Err1)]

set clone(tracespec1) [list TraceSpec $clone(TraceSpec1)]
set clone(httptransattr1) [list $clone(portattr1)]
set clone(transportattr1) [list Transports $clone(httptransattr1)]

set clone(webcontainerattr1) [list WebContainerConfig $clone(transportattr1)]

# Liste des attributs du clone
set clone(CloneAttributelist1) [list $clone(stdout1) $clone(stderr1) $clone(fullName1) $clone(tracespec1) $clone(webcontainerattr1)]
#
# CLONE XX
#


# Nom du clone
set clone(name2) [list "CloneApplicationServerXY"]

# Noeud ou tourne le clone
set clone(node2) [list "fsmiami"]

# fichier de sortie standard
set clone(Out2) [list "/tmp/Was4/scripts/test_XY_stdout"]

# Fichier de sortie d'erreur
set clone(Err2) [list "/tmp/Was4/scripts/test_XY_stderr"]

# TraceSpec
set clone(TraceSpec2) [list "fr.*=all=enabled"]

# Parametres du Plugin HTTP si on veut le configurer dans le AS ou
# le clone sinon le port est genere automatiquement a la creation
#
# Port d'ecoute
set clone(portattr2) [list Port 10056]
#
# CLONE
#


set clone(fullName2) [list Name $clone(name2)]



set clone(stdout2) [list Stdout $clone(Out2)]

set clone(stderr2) [list Stderr $clone(Err2)]

set clone(tracespec2) [list TraceSpec $clone(TraceSpec2)]
set clone(httptransattr2) [list $clone(portattr2)]
set clone(transportattr2) [list Transports $clone(httptransattr2)]

set clone(webcontainerattr2) [list WebContainerConfig $clone(transportattr2)]

# Liste des attributs du clone
set clone(CloneAttributelist2) [list $clone(stdout2) $clone(stderr2) $clone(fullName2) $clone(tracespec2) $clone(webcontainerattr2)]
set NumberOfClones 2
#
#    NOEUD WEBSPHERE
#
set nodeName [list fsdevelop2]

#
#    VIRTUAL HOST
#

# Nom du Virtual Host
set vhName [list VhSocleSample_1]
 
# Liste des Alias
set aliaslist [list *:5080]

# Ici on pourra ajouter d'autres types d'attributs 
# par exemple une MIMETABLE

#
#    SERVER GROUP
#

# Nom du ServerGroup 
set sgName [list "ServerGroupSocleSample"]

# Liste des parametres de la categorie EJBServerAttributes

# Configuration de la JVM du ServerGroup
set minheapattr [list InitialHeapSize 32]
set maxheapattr [list MaxHeapSize 64]

#
# ENTREPRISE APPLICATION
#

# Nom et chemin du fichier EAR
set earName [list "/tmp/travail/ao/SocleSampleEARv1.ear"]

# Nom de l'EnterpriseApp
set eaName [list "SocleSampleEARv1"]

# Nom du ou des modules WAR
set warName1 [list "SocleSampleWeb.war"]

#
# JDBC DRIVER
#

# Variables parametrables

set jdbcDriverName [list TestSybaseDriver2]
set implClass [list ImplClass com.sybase.jdbc2.jdbc.SybConnectionPoolDataSource]
set driverDescription [list Description {TEST JDBC Driver modifie}]

# Ici on cree des listes pour installer le driver un ou plusieurs noeud WAS
# A noter que l'ordre des items est important et ainsi a chaque noeud doit correspondre le bon fichier

set nodeInstalled [list fsdevelop2 fsmiami]
set jdbcZipfileLocation [list /tmp/travail/jconn2.jar /tmp/Was4/jconn2.jar]

#
# DATASOURCES
#

# Variables parametrables (exemple avec 2 datasources)

set dataSourceName [list DATASOURCE_SECURITE DATASOURCE_XX]

set dbName [list {databaseName FS_SV_AGF} {databaseName FS_SV_AGF}]
set ServerName [list {serverName fsdevelop2} {serverName fsdevelop2}]
set dbUser [list {user usersocle} {user usersocle}]
set dbPasswd [list {password usersocle02} {password usersocle02}]
set PortNumber [list {portNumber 8540} {portNumber 8540}]
set SqlInit [list {SQLINITSTRING {use fxxdb_securite}} {SQLINITSTRING {use fxxdb_socle}}]
set Rep_Read [list {REPEAT_READ true} {REPEAT_READ true}]
set Charset_Conv [list {CHARSET_CONVERTER_CLASS com.sybase.jdbc2.utils.TruncationConverter} {CHARSET_CONVERTER_CLASS com.sybase.jdbc2.utils.TruncationConverter}]
set Dyna_Prep [list {DYNAMIC_PREPARE true} {DYNAMIC_PREPARE true}]



set dsDescription [list {Description {DataSource securite XX modifie}} {Description {DataSource applicative XX modifie}}]
set minPoolSize [list {MinPoolSize 3} {MinPoolSize 2}]
set maxPoolSize [list {MaxPoolSize 20} {MaxPoolSize 12}]
set connTimeout [list {ConnTimeout 180} {ConnTimeout 181}]
set idleTimeout [list {IdleTimeout 1800} {IdleTimeout 1801}]
set orphanTimeout [list {OrphanTimeout 1800} {OrphanTimeout 1800}]
set statementCacheSize [list {StatementCacheSize 500} {StatementCacheSize 500}]
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

# Rapatriement de tous les parametres EJBServerAttributes
set ejbattributes [list EJBServerAttributes $jvmconfigattr]

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
