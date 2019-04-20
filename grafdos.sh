########################################################################
############################### INPUT ##################################
########################################################################


#***************************** SISTEMA ********************************#

prefix=ir2         # Los archivos tienen la forma  'prefix.pdos.pdos...'
N=                                               #Número total de átomos
EFermi=0                                   #Energía de Fermi del spin up
EFermid=0                                #Energía de Fermi del spin down

#***************************** GNUPLOT *********************************#

Title=Ir_{2}                #Gnuplot generará un .png llamado 'Title.png'
AutomaticRange=true               #Utiliza el rango automático de gnuplot
                              #Si 'true' entonces inhabilita lo siguiente
xmin=-10           #Cota mínima del rango en X de la gráfica que generará
xmax=-3            #Cota máxima del rango en X de la gráfica que generará
ymin=-5            #Cota mínima del rango en Y de la gráfica que generará
ymax=5             #Cota máxima del rango en Y de la gráfica que generará

NombreScript=scriptgraf      #Se genera un script llamado 'NombreScript'
           #Ése es modificable. Si la gráfica no es de agrado simplemente
                        #se   cambian los parámetros en él escritos, pero
    #ya no es necesario volver a correr el presente programa. Sino que se
      #ejecuta '$~ gnuplot NombreScript' con 'NombreScript' ya modificado
                  #generando un nuevo .png con los parámetros modificados


#########################################################################
############################ TERMINA INPUT ##############################
#########################################################################
















#########################################################################
########################## COMIENZA ALGORITMO ###########################
#########################################################################



wc -l $prefix.dos >> wc.tmp #Modificar pt2.dos al archivo real ###ACOPLARLO###
nl=$(awk '{print $1}' wc.tmp)
rm wc.tmp
tail -$(($nl-1)) $prefix.dos >> dos  ##REVISAR SI HAY ESPACIO EN BLANCO EN EL DOS.OUT SI SI AUMENTAR +1 AL  nl

echo "awk '{print \$1-$EFermi \" \" \$2}' dos >> DosUp$prefix.dat" >> auxiliar1
chmod +x auxiliar1; ./auxiliar1
echo "awk '{print \$1-$EFermid \" \" (-1.0)*\$3}' dos >> DosDown$prefix.dat" >> auxiliar2 #Camiar por $Simbolo
chmod +x auxiliar2; ./auxiliar2
rm auxiliar1; rm auxiliar2

echo " set terminal pngcairo size 1024,768 enhanced font 'Helvetica, 35'
set output 'DOS$prefix.png'" >> $NombreScript
echo -n "set title  \"" >> $NombreScript
echo -n "$Title" >> $NombreScript
echo "\" font \"Helvetica, 35\"">> $NombreScript
echo "set xlabel 'E-E_f (eV)' font \"Helvetica, 35\"
set ylabel 'PDOS (arbitrary units)' font \"Helvetica, 35\"
set xtics font \"Helvetica, 35\"
set yzeroaxis lt -1 lw 3
set noytics
set style fill transparent solid 0.5 noborder ">> $NombreScript

if [ $AutomaticRange = false ]
then
echo "
set xrange [$Xmin:$Xmax]
set yrange [$Ymin:$Ymax]
">> $NombreScript
fi

echo "plot \"DosUp$prefix.dat\"   u 1:2 w filledcurve below  lt rgb \"blue\" notitle,  \"DosDown$prefix.dat\" u 1:2 w filledcurve below  lt rgb \"blue\" notitle " >>  $NombreScript
gnuplot $NombreScript
#rm scriptgr

