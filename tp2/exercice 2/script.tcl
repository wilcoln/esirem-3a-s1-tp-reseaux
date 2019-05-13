# Création d'une instance de l'objet Simulator
set ns [new Simulator]

# Ouvrir le fichier trace pour nam
set nf [open out.nam w]
$ns namtrace-all $nf

# Définir la procédure de terminaison de la simulation
proc finish {} {
	global ns nf
	$ns flush-trace
	#fermer le fichier trace
		close $nf
	#Exécuter le nam avec en entrée le fichier trace
		exec nam out.nam &
		exit 0

}
	
# Insérer votre propre code pour la création de la topologie
set A [$ns node]
set B [$ns node]
set C [$ns node]
set D [$ns node]

# Labelisation des noeuds

$A label "A"
$C label "C"
$B label "B"
$D label "D"

# Création des liens entre les noeuds
$ns duplex-link $A $B 10Mb 10ms DropTail
$ns duplex-link $A $C 10Mb 10ms DropTail
$ns duplex-link $B $C 10Mb 10ms DropTail
$ns duplex-link $B $D 10Mb 10ms DropTail

# Disposition relative des noeuds
$ns duplex-link-op $A $B orient left-down
$ns duplex-link-op $A $C orient down
$ns duplex-link-op $B $D orient down
$ns duplex-link-op $B $C orient right

#Création de liaison C D
for { set i 1 } { $i <= 3 } { set i [ expr $i+1 ] } { set n($i) [$ns node] }
$ns duplex-link $C $n(1) 10Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 10Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 10Mb 10ms DropTail
$ns duplex-link $n(3) $D 10Mb 10ms DropTail

# Disposition relative des noeuds intermédiaires de la liaison C D
$ns duplex-link-op $C $n(1) orient right-down
$ns duplex-link-op $n(1) $n(2) orient down
$ns duplex-link-op $n(2) $n(3) orient left-down
$ns duplex-link-op $n(3) $D orient left

# Création de l'agent TCP
set tcp [new Agent/TCP]
$ns attach-agent $A $tcp

# Création de la source FTP
set ftp [new Application/FTP]

# Connection de la source FTP à l'agent TCP
$ftp attach-agent $tcp

# Création de l'agent TCPSink pour la réception des paquets dans n(3)
set tcpsink [new Agent/TCPSink]
$ns attach-agent $D $tcpsink

# Connection des agents TCPSink et TCP
$ns connect $tcp $tcpsink

# Changement de la forme des stations source et destination
$A shape hexagon
$D shape hexagon

# Rupture du lien entre B et D à t = 3.48s
$ns rtmodel-at 3.48 down $B $D

# Rétablissement du lien à t = 4.95s
$ns rtmodel-at 4.95 up $B $D

# Ajout du protocol de routage dynamique
$ns rtproto DV

#Déclenchement du traffic N1 à 1.0s et fin du traffic à 7.0s
$ns at 1. "$ftp start"
$ns at 7. "$ftp stop"

# Appeler la procédure de terminaison après un temps t (ex t=5s)

$ns at 8.0 "finish"

# Exécuter la simulation
$ns run
