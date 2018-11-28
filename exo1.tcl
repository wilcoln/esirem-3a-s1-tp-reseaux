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

set n(0) [$ns node]
set n(1) [$ns node]
$ns duplex-link $n(0) $n(1) 1Mb 10ms DropTail

# Création de l'agent UDP
set udp [new Agent/UDP]
$ns attach-agent $n(0) $udp

# Création de la source de traffic CBR
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set interval_ .005

# Connection de la source à l'agent udp
$cbr attach-agent $udp

# Création de l'agent Null pour la réception des paquets dans n(1)

set null [new Agent/Null]
$ns attach-agent $n(1) $null

#Connection des agents Null et UDP
$ns connect $udp $null

#Déclenchement du traffic
$ns at 1 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5 "finish"


# Appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 5.0 "finish"

# Exécuter la simulation
$ns run
