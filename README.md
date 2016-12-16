#BarCamp

BarCamp MDQ, desarrollada por GlobalLogic Latinoamérica, replica la clásica pizarra del evento para que puedas consultar online las charlas que se suman, ¡en tiempo real y sin moverte de la sala! Además, realiza un seguimiento del evento en Twitter para que no te pierdas ni una conversación.

BarCamp es un open space que reune a estudiantes, profesionales y geeks apasionados por el desarrollo de software, ingeniería, comunicaciones y afines, con el propósito de intercambiar experiencias y conocimientos, mediante la realización de charlas, talleres y debates. La agenda es espontánea y planeada entre todos al inicio del evento.

Support: https://www.globallogic.com/latam/contact-us/

## Configuración Inicial

###Registrar instancia en Firebase

1. Crea un proyecto de Firebase en el [Firebase console](https://firebase.google.com/console/) , si aún no tienes uno. Si ya tienes un proyecto de Google asociado con tu app para dispositivos móviles, haz clic en **Import Google Project**. De lo contrario, haz clic en **Create New Project**.
2. Haz clic en **Add Firebase to your Android app** y sigue los pasos de configuración. Si estás importando un proyecto de Google existente, esto puede realizarse automáticamente y podrás descargar el archivo de configuración.
3. Cuando se te indique, ingresa el nombre del paquete de tu app. Es importante ingresar el nombre del bundle que está usando tu app; esto solo se puede configurar cuando agregas una app a tu proyecto de Firebase.
4. Al final, descargarás un archivo `GoogleService-Info.plist`. Puedes [descargar este archivo](http://support.google.com/firebase/answer/7015592) nuevamente en cualquier momento. Luego reemplaza ese archivo en la ruta `bar-camp/Resources/Dev/GoogleService-Info.plist` para ambiente de desarrollo y `bar-camp/Resources/Dev/GoogleService-Info.plist` para producción. 

Busca más información en: https://firebase.google.com/docs/ios/setup


###Configuración local

BarCamp iOS consume también los servicios de Fabric, Twitter y Facebook. Por ello debes registrar la aplicación en las respectivas plataformas y obtener las keys. 

* [Twitter](https://docs.fabric.io/apple/twitter/installation.html)
* [Crashlytics](https://docs.fabric.io/apple/fabric/overview.html)
* [Facebook](https://github.com/facebook/facebook-ios-sdk)

Una vez obtengas las credenciales, debes reemplazarlas en los archivos `bar-camp/Resources/Dev/BarCamp MDQ-Dev.plist` y `bar-camp/Resources/Dev/BarCamp MDQ-Prod`. La siguiente imagen refleja con exactitud los valores que debes reeplazar.

![API_KEYS](/Docs/BarCamp_MDQ-Dev_plist.png)

## Arquitectura
BarCamp iOS usa [Clean Swift](http://clean-swift.com/)
