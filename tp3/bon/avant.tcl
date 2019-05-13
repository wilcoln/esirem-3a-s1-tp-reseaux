set ns [new Simulator]
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]
#Création de 5 Noeuds
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
#Etablissment de 4 liens duplex: 0-3 1-3 2-3 et 3-4
$ns duplex-link $n0 $n3 1Mb 100ms DropTail
$ns duplex-link $n1 $n3 1Mb 100ms DropTail
$ns duplex-link $n2 $n3 1Mb 100ms DropTail
$ns duplex-link $n3 $n4 1Mb 100ms DropTail
proc finish {} {
#Fin de la simulation
global f0 f1 f2
close $f0
close $f1
close $f2
#On affiche une fenetre xgraph de 800*400 avec 3 signaux
exec xgraph out0.tr out1.tr out2.tr -geometry 800x400 &
exit 0
}
proc attach-expoo-traffic { node sink size burst idle rate} {
#Passage en paramètres d'un noeud, d'un agent, d'une taille, d'un burst-time, d'une idel-time et d'un débit
set ns [Simulator instance]
#Création d'une simulation
set source [new Agent/UDP]
#On crée une source et on l'attache au noeud en paramètre
$ns attach-agent $node $source
set traffic [new Application/Traffic/Exponential]
#On crée une nouvelle application en lui donnant les paramètres voulus puis on l'attache à l'agent
$traffic set packetSize_ $size
$traffic set burst_time_ $burst
$traffic set idle_time_ $idle
$traffic set rate_ $rate
$traffic attach-agent $source
$ns connect $source $sink
#On attache notre nouvel agent à l'agent passé en paramètre
return $traffic
#On retourne l'application crée
}
proc record {} {
#Fonction d'enregistrement
global sink0 sink1 sink2 f0 f1 f2
#Création d'une simulation
set ns [Simulator instance]
#On fixe le temps d'enregistrement à 0.5s
set time 0.5
set bw0 [$sink0 set bytes_]
#On trace bw0 en fonction du nombre d'octet transmit sur sink0
set bw1 [$sink1 set bytes_]
set bw2 [$sink2 set bytes_]
set now [$ns now]
#On enregistre les relevés obtenus sur les 3 fichiers crées
puts $f0 "$now [expr $bw0/$time*8/1000000]"
puts $f1 "$now [expr $bw1/$time*8/1000000]"
puts $f2 "$now [expr $bw2/$time*8/1000000]"
$sink0 set bytes_ 0
$sink1 set bytes_ 0
$sink2 set bytes_ 0
#On appelle la fonction record toutes les $time secondes
$ns at [expr $now+$time] "record"
}
#On crée 3 Agents
set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
#On attache ces agents au noeud 4
$ns attach-agent $n4 $sink0
$ns attach-agent $n4 $sink1
$ns attach-agent $n4 $sink2
#On appelle la fonction attach-expoo-traffic 3 fois pour réaliser une meme fonction
set source0 [attach-expoo-traffic $n0 $sink0 200 2s 1s 100k 1]
set source1 [attach-expoo-traffic $n1 $sink1 200 2s 1s 100k 2]
set source2 [attach-expoo-traffic $n2 $sink2 200 2s 1s 100k 3]
#On commence l'enregistrement
$ns at 0.0 "record"
#On commence l'émission
$ns at 10.0 "$source0 start"
$ns at 10.0 "$source1 start"
$ns at 10.0 "$source2 start"
$ns at 50.0 "$source0 stop"
$ns at 50.0 "$source1 stop"
$ns at 50.0 "$source2 stop"
$ns at 60.0 "finish"
$ns run