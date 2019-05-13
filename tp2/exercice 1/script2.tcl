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

#Définit les couleurs des différents flux 
$ns color 1 Blue
$ns color 2 Red
	
# Création des noeuds
set nodeNb 8
for { set i 1 } { $i <= $nodeNb } { set i [ expr $i+1 ] } { set n($i) [$ns node] }

# Création des liens entre les noeuds
$ns duplex-link $n(1) $n(3) 10Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 10Mb 10ms DropTail
$ns duplex-link $n(3) $n(4) 10Mb 10ms DropTail
$ns duplex-link $n(3) $n(5) 10Mb 10ms DropTail
$ns duplex-link $n(5) $n(8) 10Mb 10ms DropTail
$ns duplex-link $n(4) $n(6) 10Mb 10ms DropTail
$ns duplex-link $n(6) $n(7) 10Mb 10ms DropTail
$ns duplex-link $n(7) $n(8) 10Mb 10ms DropTail

#Positionnement des noeuds
$ns duplex-link-op $n(1) $n(3) orient right-down
$ns duplex-link-op $n(3) $n(2) orient right-up
$ns duplex-link-op $n(3) $n(4) orient right
$ns duplex-link-op $n(5) $n(3) orient right-up
$ns duplex-link-op $n(5) $n(8) orient right-down
$ns duplex-link-op $n(4) $n(6) orient right-down
$ns duplex-link-op $n(7) $n(6) orient right-up
$ns duplex-link-op $n(8) $n(7) orient right

# Création des agents UDP
set udp(1) [new Agent/UDP]
$ns attach-agent $n(1) $udp(1)

# On affecte la classe de l'agent UDP à 1
$udp(1) set class_ 1

set udp(2) [new Agent/UDP]
$ns attach-agent $n(2) $udp(2)

# On affecte la classe de l'agent UDP à 2
$udp(2) set class_ 2

# Création des sources de traffic CBR
set cbr(1) [new Application/Traffic/CBR]
$cbr(1) set packetSize_ 500
$cbr(1) set interval_ .005

set cbr(2) [new Application/Traffic/CBR]
$cbr(2) set packetSize_ 500
$cbr(2) set interval_ .005

# Attache de cbr1 et cbr2 à udp1 et udp2
$cbr(1) attach-agent $udp(1)
$cbr(2) attach-agent $udp(2)

# Création de l'agent Null pour la réception des paquets dans N8
set null [new Agent/Null]
$ns attach-agent $n(8) $null

# Connection des agents Null et UDP1 et UDP2
$ns connect $udp(1) $null
$ns connect $udp(2) $null

# Déclenchement du traffic N1 à 1.0s et fin du traffic à 7.0s
$ns at 1. "$cbr(1) start"
$ns at 7. "$cbr(1) stop"

# Déclenchement du traffic N2 à 2.0s et fin du traffic à 6.0s
$ns at 2. "$cbr(2) start"
$ns at 6. "$cbr(2) stop"

# Rupture du lien entre N5 et N8 at t = 4.0s
$ns rtmodel-at 4.0 down $n(5) $n(8)

# Rétablissement du lien entre N5 et N8 at t = 5.0s
$ns rtmodel-at 5.0 up $n(5) $n(8)

# Ajout du protocol de routage dynamique
$ns rtproto LS

# Appeler la procédure de terminaison après 8.0s
$ns at 8.0 "finish"

# Exécuter la simulation
$ns run
