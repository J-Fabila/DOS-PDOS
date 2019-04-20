########################################################################
############################### INPUT ##################################
########################################################################


#***************************** SISTEMA ********************************#

prefix=ir2         # Los archivos tienen la forma  'prefix.pdos.pdos...'
N=110                                            #Número total de átomos
EFermi=0                                   #Energía de Fermi del spin up
EFermid=0                                #Energía de Fermi del spin down

Simbolo_1=Au             #Aquí se declaran los tipos de átomos que tiene
Simbolo_2=Ir                 #el sistema, al final se escribe un resumen
Simbolo_3=Ti                  #de colores, especies atómicas y orbitales
Simbolo_4=O

#***************************** GNUPLOT ********************************#

Title=Ir_{2}               #Gnuplot generará un .png llamado 'Title.png'

AutomaticRange=false              #Utiliza el rango automático de gnuplot
                        #Si 'true' entonces se  inhabilita lo siguiente:
xmin=-6          #Cota mínima del rango en X de la gráfica que generará
xmax=6           #Cota máxima del rango en X de la gráfica que generará

NombreScript=scriptgrafpdos  #Se genera un script llamado 'NombreScript'
          #ése es modificable. Si la gráfica no es de agrado simplemente
                       #se   cambian los parámetros en él escritos, pero
   #ya no es necesario volver a correr el presente programa. Sino que se
     #ejecuta '$~ gnuplot NombreScript' con 'NombreScript' ya modificado
                 #generando un nuevo .png con los parámetros modificados


#########################################################################
############################ TERMINA INPUT ##############################
#########################################################################
















#########################################################################
########################## COMIENZA ALGORITMO ###########################
####################################################
#####################

#************************* Arreglo de colores **************************#


color=(white white white white white white navy purple blue olive grey red  golden coral  magenta brown greenyellow aquamarine blueviolet  royalblue \#00BFFF \#008B8B \#006400 )
#00BFFF=Deepskyblue
#008B8B=darkcyan
#006400=darkgreen
#***********************************************************************#


#***********************************************************************#
#     Lee el archivo 'coords' y borra los átomos en él seleccionados    #
#***********************************************************************#

if [ -f coords ]         #Si el archivo existe, lo lee y borra los átomos
then               #seleccionados, si no existe entonces asume que deberá
                                 #graficar todos los archivos disponibles
   for (( i=1;i<$(($N+1));i++ ))
   do

#*************PARSER: analiza si el �tomo est� seleccionado*************#

      VAR=$(head -$i coords | tail -1 | awk '{print $5}' | wc -c )

#***************************Termina parser******************************#

      if [ $VAR -gt 1 ]         #Significa que el �tomo est� seleccionado
      then
      rm *#$i\(*wfc*      #Borra los pdos del atomo que est� seleccionado
      echo "$i"
      fi

   done 2>/dev/null

fi
#**********************Extrae las energ�as de Fermi*********************#


#************************Genera los archivos .dat***********************#

for ((l=1;l<(($N+1)); l++))
do
   for m in $(ls $prefix.pdos.pdos_atm#$l*)
   do
#      nl=$(cat $m | wc -l )
   wc -l $m  >> wc.tmp
  nl=$(awk '{print $1}' wc.tmp)
      tail -$(($nl-20)) $m >> pdos$m
      rm wc.tmp
      echo "awk '{print \$1-$EFermi \" \" \$2}' 'pdos$m' >> 'PdosUp$m.dat'" >> auxiliar1
chmod +x auxiliar1; ./auxiliar1
echo "awk '{print \$1-$EFermid \" \" (-1.0)*\$3}' 'pdos$m' >> 'PdosDown$m.dat'" >> auxiliar2 #Camiar por $Simbolo
chmod +x auxiliar2; ./auxiliar2
rm auxiliar1; rm auxiliar2


     done
done 2>/dev/null

#***********************************************************************#
#                      ESCRIBE SCRIPTS PARA GNUPLOT                     #
#***********************************************************************#


echo "set terminal pngcairo size 1024,768 enhanced font 'Helvetica, 35'
set output '$Title.png'" >> $NombreScript
echo -n "set title \"" >> $NombreScript
echo -n "$Title" >> $NombreScript
echo "\" font \"Helvetica, 35\"">> $NombreScript
echo "set xlabel 'E-E_f (eV)'  font \"Helvetica, 35\"
set ylabel 'PDOS (arbitrary units)' font \"Helvetica, 35\"
set xtics font \"Helvetica, 35\"
set yzeroaxis lt -1 lw 3
set noytics " >> $NombreScript


if [ $AutomaticRange = false ]
then
echo "
set xrange [$xmin:$xmax]
">> $NombreScript
fi


echo "set style fill transparent solid 0.3 noborder ">> $NombreScript
echo -n "plot  " >> $NombreScript
for ((l=1;l<$(($N+1)); l++))
do

   multiplicidad=$( ls $prefix.pdos.pdos_atm#$l\(* | wc -l ) #Cuenta el numero de orbitales tiene el l-esimo atomo

   for ((m=$multiplicidad;m>0;m--))
   do
        fileup=$(ls PdosUp*atm#$l\(*wfc#$m*.dat)
        filedown=$(ls PdosDown*atm#$l\(*wfc#$m*.dat)


#************** Parser que determina el tipo de orbital **************#

        echo "$fileup" >> atomos
        orbital=$(cut -f 3 -d '(' atomos | cut -f 1 -d ')')
        rm atomos

#*********************Parser que determina el tipo de Átomo**********************#

        echo "$fileup" >> atomos
        tipo=$(cut -f 2 -d '(' atomos | cut -f 1 -d ')')
        rm atomos

#*********************************************************************#
#              Asigna colores                                  #
#********************************************************************#




#*************************** Spin up ************************************#

        echo -n "\"$fileup\" u 1:2 w filledcurve below lt rgb " >> $NombreScript



        case "$tipo" in 
           $Simbolo_1)

                case "$orbital" in
                     s)
                     echo -n " \"${color[1]}\" notitle, " >> $NombreScript
                     ;;
                     p)
                     echo -n " \"${color[2]}\" notitle, " >> $NombreScript
                     ;;
                     d)
                     echo -n " \"${color[3]}\" notitle, " >> $NombreScript
                     ;;
                     f)
                     echo -n " \"${color[4]}\" notitle, " >> $NombreScript
                     ;;
                     g)
                     echo -n " \"${color[5]}\" notitle, " >> $NombreScript
                     ;;
                esac
   
            ;;

           $Simbolo_2)

                case "$orbital" in
                     s)
                     echo -n " \"${color[6]}\" notitle, " >> $NombreScript
                     ;;
                     p)
                     echo -n " \"${color[7]}\" notitle, " >> $NombreScript
                     ;;
                     d)
                     echo -n " \"${color[8]}\" notitle, " >> $NombreScript
                     ;;
                     f)
                     echo -n " \"${color[9]}\" notitle, " >> $NombreScript
                     ;;
                     g)
                     echo -n " \"${color[10]}\" notitle, " >> $NombreScript
                     ;;
                esac
            ;;

           $Simbolo_3)

                case "$orbital" in
                     s)
                     echo -n " \"${color[11]}\" notitle, " >> $NombreScript
                     ;;
                     p)
                     echo -n " \"${color[12]}\" notitle, " >> $NombreScript
                     ;;
                     d)
                     echo -n " \"${color[13]}\" notitle, " >> $NombreScript
                     ;;
                     f)
                     echo -n " \"${color[14]}\" notitle, " >> $NombreScript
                     ;;
                     g)
                     echo -n " \"${color[15]}\" notitle, " >> $NombreScript
                     ;;
                esac
            ;;

            $Simbolo_4)
                case "$orbital" in
                     s)
                     echo -n " \"${color[16]}\" notitle, " >> $NombreScript
                     ;;
                     p)
                     echo -n " \"${color[17]}\" notitle, " >> $NombreScript
                     ;;
                     d)
                     echo -n " \"${color[18]}\" notitle, " >> $NombreScript
                     ;;
                     f)
                     echo -n " \"${color[19]}\" notitle, " >> $NombreScript
                     ;;
                     g)
                     echo -n " \"${color[20]}\" notitle, " >> $NombreScript
                     ;;
                esac
            ;;

         esac






#*************************** Spin down ************************************#



        echo -n "\"$filedown\" u 1:2  w filledcurve below lt rgb " >> $NombreScript






        case "$tipo" in 
           $Simbolo_1)

                case "$orbital" in
                     s)
                     echo -n " \"${color[1]}\" notitle, " >> $NombreScript
                     ;;
                     p)
                     echo -n " \"${color[2]}\" notitle, " >> $NombreScript
                     ;;
                     d)
                     echo -n " \"${color[3]}\" notitle, " >> $NombreScript
                     ;;
                     f)
                     echo -n " \"${color[4]}\" notitle, " >> $NombreScript
                     ;;
                     g)
                     echo -n " \"${color[5]}\" notitle, " >> $NombreScript
                     ;;
                esac
   
            ;;

           $Simbolo_2)

                case "$orbital" in
                     s)
                     echo -n " \"${color[6]}\" notitle, " >> $NombreScript
                     ;;
                     p)
                     echo -n " \"${color[7]}\" notitle, " >> $NombreScript
                     ;;
                     d)
                     echo -n " \"${color[8]}\" notitle, " >> $NombreScript
                     ;;
                     f)
                     echo -n " \"${color[9]}\" notitle, " >> $NombreScript
                     ;;
                     g)
                     echo -n " \"${color[10]}\" notitle, " >> $NombreScript
                     ;;
                esac
            ;;

           $Simbolo_3)

                case "$orbital" in
                     s)
                     echo -n " \"${color[11]}\" notitle, " >> $NombreScript
                     ;;
                     p)
                     echo -n " \"${color[12]}\" notitle, " >> $NombreScript
                     ;;
                     d)
                     echo -n " \"${color[13]}\" notitle, " >> $NombreScript
                     ;;
                     f)
                     echo -n " \"${color[14]}\" notitle, " >> $NombreScript
                     ;;
                     g)
                     echo -n " \"${color[15]}\" notitle, " >> $NombreScript
                     ;;
                esac
            ;;

            $Simbolo_4)
                case "$orbital" in
                     s)
                     echo -n " \"${color[16]}\" notitle, " >> $NombreScript
                     ;;
                     p)
                     echo -n " \"${color[17]}\" notitle, " >> $NombreScript
                     ;;
                     d)
                     echo -n " \"${color[18]}\" notitle, " >> $NombreScript
                     ;;
                     f)
                     echo -n " \"${color[19]}\" notitle, " >> $NombreScript
                     ;;
                     g)
                     echo -n " \"${color[20]}\" notitle, " >> $NombreScript
                     ;;
                esac
            ;;

         esac



   done
done 2>/dev/null
gnuplot $NombreScript


echo "Se utilizaron los siguientes colores:

Tipo   Orbital    Color

$Simbolo_1      \"s\"   ${color[1]}
$Simbolo_1      \"p\"   ${color[2]}
$Simbolo_1      \"d\"   ${color[3]}
$Simbolo_1      \"f\"   ${color[4]}
$Simbolo_1      \"g\"   ${color[5]}
$Simbolo_2      \"s\"   ${color[6]}
$Simbolo_2      \"p\"   ${color[7]}
$Simbolo_2      \"d\"   ${color[8]}
$Simbolo_2      \"f\"   ${color[9]}
$Simbolo_2      \"g\"   ${color[10]}
$Simbolo_3      \"s\"   ${color[11]}
$Simbolo_3      \"p\"   ${color[12]}
$Simbolo_3      \"d\"   ${color[13]}
$Simbolo_3      \"f\"   ${color[14]}
$Simbolo_3      \"g\"   ${color[15]}
$Simbolo_4      \"s\"   ${color[16]}
$Simbolo_4      \"p\"   ${color[17]}
$Simbolo_4      \"d\"   ${color[18]}
$Simbolo_4      \"f\"   ${color[19]}
$Simbolo_4      \"g\"   ${color[20]}">>Acotaciones

rm pdos*
