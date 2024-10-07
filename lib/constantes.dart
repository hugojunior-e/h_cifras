import 'package:flutter/material.dart';
import 'database_helper.dart';

DatabaseHelper ddb = DatabaseHelper();

const String constTitulo = 'Hugo Jr - Cifras';

const String constHTML = """
        <style>
           b { color: red; font-weight: bold; font-size: 40px;}
           h1{
                font-size: 40px;
            }
            pre {
                line-height: 1.6;
                font-size: 40px;
            }
        </style>
        <script>
               var i_letra=0;
               var i_yt=0;

               function fta() {
                 return document.all.tom_atual.innerHTML;
               }

               function mudarTom(nota2, tipoMud) {
                lista = ['C','D','E','F','G','A','B'];
                nota = '';

                for (j = 0; j < 7; j++) {
                   if ( nota2.indexOf(lista[j]) >= 0 )
                     nota = lista[j];
                }
                if ( nota == '' ) 
                  return [];

                if ( nota2.indexOf("#") >= 0 )
                  nota = nota + "#";

                if ( nota2.indexOf("b") >= 0 )
                  nota = nota + "b";

                notas = [ 'C', 'C#/Db', 'D', 'D#/Eb', 'E/Fb', 'F', 'F#/Gb', 'G','G#/Ab', 'A', 'A#/Bb', 'B/Cb'  ];

                for (i = 0; i < notas.length; i++) {

                  a = nota == notas[i];
                  b = notas[i].search(nota + "/") >= 0;
                  c = notas[i].search("/" + nota + "\$") > 0;

                  if ( a || b || c  )
                  {
                    idx = (a || b) ? 0 : 1;
                    if (tipoMud == '+')
                    {
                        if (i == notas.length-1 )
                        {
                          dat = notas[0].split("/");
                        }
                        else
                        {
                          dat = notas[i+1].split("/");
                        }
                    }
                    else
                    {
                        if (i == 0 )
                        {
                            dat = notas[notas.length-1].split("/");
                        }
                        else
                        {
                            dat = notas[i-1].split("/");
                        }
                    }

                    return [nota, ( dat[dat.length == 1 ? 0 : idx]   )  ];

                  }
                }
              }

              function rep(tipo) {
                  document.querySelectorAll("b").forEach( e => {

                      nota_ele_e = e.innerHTML.trim();
                      l_notas    = nota_ele_e.split("/");

                      l_notas.forEach( (i_nota) => {
                          nota_nova   = mudarTom( i_nota,tipo );
                          if ( nota_nova.length > 0)
                            nota_ele_e  = nota_ele_e.replace(nota_nova[0], nota_nova[1] );
                       });
                      e.innerHTML = nota_ele_e;
                  });
              }

              function go_to_tom(xxx) {
                  for (i=1; i <= 12; i++)
                  {
                      if ( xxx == fta() )
                        return;
                     rep('+');
                  }

              }

              function letra() {
                  i_letra = 1 - i_letra;
                  document.querySelectorAll("b").forEach( e => {
                      e.style.visibility = i_letra == 0 ? '' : 'hidden';
                  });              
              }       

              function fyt(tt) {
                i_yt = 1 - i_yt;

                if ( i_yt == 0 )
                  document.all.yt.innerHTML = '';
                else
                {  
                  if (tt.length == 0)
                    document.all.yt.innerHTML = '';
                  else  
                    document.all.yt.innerHTML = '<center><iframe src="https://www.youtube.com/embed/' + tt + '" width=1200 height=800 frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe></center>';
                }
              }       
        </script>
        <div id=yt></div>
        <br><h1>Tom: <b id=tom_atual>#TOM#</b></h1> 
        <div>
          #CIFRA#
        </div>
""";

showAlertDialog(BuildContext context, String title, String message) {
  // set up the button
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
