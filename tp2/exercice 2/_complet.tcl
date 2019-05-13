#Création d'une instance de l'objet Simulator
set ns [new Simulator]
#Ouvrir le fichier trace pour nam
set nf [open out.nam w]
$ns namtrace-all $nf
#Définir la procédure de terminaison de la simulation
proc finish {} {
global ns nf
$ns flush-trace
#fermer le fichier trace
close $nf
#Exécuter le nam avec en entrée le fichier trace
exec nam out.nam &
exit 0
}
set A [$ns node]
$A label "A"
$A shape hexagon
set B [$ns node]
$B label "B"
set C [$ns node]
$C label "C"
set D [$ns node]
$D label "D"
$D shape hexagon
for {set i 1} {$i<=3} {set i [expr $i+1]} {set n($i) [$ns node]}
$ns duplex-link $A $B 10Mb 10ms DropTail
$ns duplex-link $A $C 10Mb 10ms DropTail
$ns duplex-link $C $B 10Mb 10ms DropTail
$ns duplex-link $D $B 10Mb 10ms DropTail
$ns duplex-link $C $n(1) 10Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 10Mb 10ms DropTail
$ns duplex-link $n(2) $n(3) 10Mb 10ms DropTail
$ns duplex-link $n(3) $D 10Mb 10ms DropTail
set transp1 [new Agent/TCP]
set transp2 [new Agent/TCPSink]
set app [new Application/FTP]
$app attach-agent $transp1
$app set packetSize_ 5
$ns attach-agent $A $transp1
$ns attach-agent $D $transp2
$ns connect $transp1 $transp2
$ns color 1 Blue
$transp1 set class_ 1
$transp2 set class_ 1
$ns rtproto DV
$ns rtmodel-at 3.48 down $B $D
$ns rtmodel-at 4.95 up $B $D
$ns at 1.0 "$app start"
$ns at 7.0 "$app stop"
$ns at 8.0 "finish"
$ns run