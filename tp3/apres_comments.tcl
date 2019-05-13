# Création d'une nouvelle instance de simulateur
set ns [new Simulator]

# Ouverture en écriture de trois fichiers traces
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]

# Création d'un fichier out.nam
set nf [open out.nam w]
$ns namtrace-all $nf

# Défintion des couleurs
$ns color 1 Red
$ns color 2 Green
$ns color 3 Blue

# Création de 5 noeuds
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Etablissment de liens duplex: 0-3 1-3 2-3 et 3-4
$ns duplex-link $n0 $n3 1Mb 100ms DropTail
$ns duplex-link $n1 $n3 1Mb 100ms DropTail
$ns duplex-link $n2 $n3 1Mb 100ms DropTail
$ns duplex-link $n3 $n4 1Mb 100ms DropTail

# Définition de la procédure de fin de simulation
proc finish {} {
    global f0 f1 f2 ns nf
    $ns flush-trace
    # Execution de nam avec pour entrée le fichier trace
    exec nam out.nam &

    # Ferme les fichiers traces
    close $f0
    close $f1
    close $f2
    # Ouvre une fenêtre xgraph de dimension 800*400 et trace le contenu des 3 fichiers traces de sortie
    exec xgraph out0.tr out1.tr out2.tr -geometry 800x400 &
    # Arret de la simulation
    exit 0
}

proc attach-expoo-traffic { node sink size burst idle rate color} {
    # Passage en paramètres d'un noeud, d'un agent, d'une taille, d'un burst-time, d'une idel-time et d'un débit

    # Récupération de l'instance courante du simulateur
    set ns [Simulator instance]

    # Création d'un agent udp et attachement de cet agent au noeud node
    set source [new Agent/UDP]
    $ns attach-agent $node $source
    # Associe la couleur color à la source
    $source set class_ $color

    # Création d'une application de caractéristiques définies par les paramètres
    set traffic [new Application/Traffic/Exponential]
    $traffic set packetSize_ $size
    $traffic set burst_time_ $burst
    $traffic set idle_time_ $idle
    $traffic set rate_ $rate

    # Attachement de l'agent udp créé à la nouvelle application
    $traffic attach-agent $source
    # Connexion de l'agent udp créé attaché à la source à l'agent sink passé en paramètre
    $ns connect $source $sink
    # On retource l'application créée
    return $traffic
}
proc record {} {
    #Fonction de sauvegarde
    global sink0 sink1 sink2 f0 f1 f2
    # Récupération de l'instance de simulation courante
    set ns [Simulator instance]
    # On fixe la période des enregistrements à 0.5s
    set time 0.5
    # On trace les bwi (avec i dans 0,1,2) en fonction du nombre d'octet transmit sur sink0
    set bw0 [$sink0 set bytes_]
    set bw1 [$sink1 set bytes_]
    set bw2 [$sink2 set bytes_]
    set now [$ns now]
    # On note les relevés obtenus dans les 3 fichiers traces
    puts $f0 "$now [expr $bw0/$time*8/1000000]"
    puts $f1 "$now [expr $bw1/$time*8/1000000]"
    puts $f2 "$now [expr $bw2/$time*8/1000000]"
    $sink0 set bytes_ 0
    $sink1 set bytes_ 0
    $sink2 set bytes_ 0
    # Appel à la fonction record toute les .5s
    $ns at [expr $now+$time] "record"
}

# Création de 3 agents de type LossMonitor
set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
# Attachement de ces agents au noeud 4
$ns attach-agent $n4 $sink0
$ns attach-agent $n4 $sink1
$ns attach-agent $n4 $sink2

# Appel de la fonction attach-expoo-traffic 3 fois avec des paramètres différents pour définir trois traffics distincts
# Modification des appels à la fonction pour prise en compte de la couleur
set source0 [attach-expoo-traffic $n0 $sink0 200 2s 1s 100k 1]
set source1 [attach-expoo-traffic $n1 $sink1 200 2s 1s 100k 2]
set source2 [attach-expoo-traffic $n2 $sink2 200 2s 1s 100k 3]

$ns at 0.0 "record"

# Déclenche les 3 traffics à t=10.0s
$ns at 10.0 "$source0 start"
$ns at 10.0 "$source1 start"
$ns at 10.0 "$source2 start"
# Arrête les traffics à t=50.0s
$ns at 50.0 "$source0 stop"
$ns at 50.0 "$source1 stop"
$ns at 50.0 "$source2 stop"
# Appel à la procédure finish pour terminer la simulation à t=60.0s
$ns at 60.0 "finish"

# Lance la simulation
$ns run