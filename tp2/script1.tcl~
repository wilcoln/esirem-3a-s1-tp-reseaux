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
set nodeNb 8
for { set i 1 } { $i <= $nodeNb } { set i [ expr $i+1 ] } { set n($i) [$ns node] }

#for { set i 1 } { $i <= $nodeNb } { set i [ expr $i+1 ] } { set udp($i) [new Agent/UDP]}
#for { set i 1 } { $i <= $nodeNb } { set i [ expr $i+1 ] } { $ns attach-agent $n($i) $udp($i) }

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
$ns duplex-link-op $n(3) $n(4) orient right-up
$ns duplex-link-op $n(5) $n(3) orient right-up
$ns duplex-link-op $n(5) $n(8) orient right-down
$ns duplex-link-op $n(4) $n(6) orient right-down
$ns duplex-link-op $n(7) $n(6) orient right-up
$ns duplex-link-op $n(8) $n(7) orient right

# Création des agents UDP
set udp(1) [new Agent/UDP]
$ns attach-agent $n(1) $udp(1)
set udp(2) [new Agent/UDP]
$ns attach-agent $n(2) $udp(2)

# Création des sources de traffic CBR
set cbr(1) [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set interval_ .005

set cbr(2) [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set interval_ .005

# Attache de cbr1 et cbr2 à N1 et N2
$ns attach-agent $n(1) $cbr(1)
$ns attach-agent $n(2) $cbr(2)

# Création de l'agent Null pour la réception des paquets dans N8
set null [new Agent/Null]
$ns attach-agent $n(8) $null

#Déclenchement du traffic cbr à .1 et fin du traffic à 4.5
$ns at 1. "$cbr(1) start"
$ns at 7. "$cbr(1) stop"

#Déclenchement du traffic ftp à 1 et fin du traffic à 4
$ns at 2. "$cbr(2) start"
$ns at 6. "$cbr(2) stop"

# Rupture du lien entre N5 et N8 at t = 4.0s

# Rétablissement du lien entre N5 et N8 at t = 5.0s

# Appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 8.0 "finish"

# Exécuter la simulation
$ns run
