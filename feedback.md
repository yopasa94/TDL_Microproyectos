# Microproyecto 1
RúbricaRúbrica                                         Rúbrica                                         

Puntuación:
0 de 5 puntos

Buen trabajo.

Introducción (Excelente, 1.00/1): Bien.

Metodología (Bueno, 0.65/1): Describen ampliamente el pipeline, las arquitecturas y los hiperparámetros. Falta citar la fuente del dataset y justificar la pérdida y las métricas, especialmente la sensibilidad frente a tumores clasificados como sanos. Como recomendación, aclaren que el Sub-Test de 208 imágenes también participa en la selección interna de la arquitectura; el Test final de 990 imágenes permanece separado.

Resultados:

Cualitativos (Excelente, 1.00/1): Bien.

Cuantitativos (Excelente, 1.00/1): Bien. Como recomendación, pueden dar más espacio a las tablas para facilitar su lectura.

Discusión (Bueno, 0.65/1): Las explicaciones causales exceden la evidencia: al cambiar varias decisiones a la vez no pueden aislar sus efectos ni demostrar que el modelo utilice únicamente el parénquima. El intervalo 44.9–78.6 % corresponde a medias de confianza por tipo de error, no al rango de las doce predicciones; la Fig. 1 incluye un error con 92.8 %. Esos promedios no demuestran ausencia de sobreconfianza. Falta además contrastar el desempeño con trabajos relacionados.

Redacción y ortografía (Excelente, 0.80/1): Falta concisión en la descripción de las arquitecturas: separen las ideas y reduzcan las enumeraciones extensas. Corrijan también “un metodo”, “arquitectura seleccionado” y la descripción de la Fig. 1, que muestra un acierto por clase.

Formato (Excelente, 1.00/1): Bien.

Código:

Entrega (Excelente, 1/1): Bien.

Orden (Excelente, 1/1): Bien. Como recomendación, identifiquen el Sub-Test como parte del proceso interno de selección de arquitectura y distingan ese uso del Test final independiente.

Nota final informe: 3.88/4.5

Nota final código: 0.50/0.5

Nota final: 4.38/5.0

Nota final Coursera: 87.6/100

# Microproyecto 2

RúbricaRúbrica                                         Rúbrica                                         

Puntuación:
0 de 5 puntos

Introducción (Excelente, 1/1): Bien.

Metodología (Excelente, 0.95/1): Bien. Falta citar la fuente del subconjunto de 40 000 reseñas que usaron: la referencia [3] corresponde al corpus original de 50 000. Como recomendación, en este tipo de artículos no se incluyen los nombres de funciones y clases (pack_padded_sequence, BucketBatchSampler, BCEWithLogitsLoss); en vez de esto se describe lo que se hizo.  

Resultados Cualitativos (Bueno, 0.58/1): Incluyen seis reseñas con su predicción, la probabilidad y los tokens más influyentes, con aciertos y errores interpretados, pero todo queda en un párrafo, sin una figura o tabla numerada y referenciada que permita comparar la predicción con la etiqueta real. Además, las seis reseñas las escribieron ustedes y no son reseñas del conjunto de prueba (el informe no lo aclara), la etiqueta real no aparece escrita junto a cada predicción, y la oclusión de tokens y la distribución bimodal se mencionan sin ninguna figura. Lleven al informe una tabla o figura con fragmentos de reseñas de prueba bien y mal clasificadas (fragmento, etiqueta real, predicción y tokens resaltados), como las que ya genera su notebook, y refiéranlas en el texto.

Resultados Cuantitativos (Excelente, 0.95/1): Bien. La Tabla I tiene la letra muy pequeña y su pie no aclara que las corridas usan el 25 % de Train ni que el F1 es el de la clase positiva (en Test reportan el macro), así que ambas cifras no son comparables; además, con solo dos semillas la desviación dice poco. Como recomendación, el tiempo de entrenamiento no es relevante para evaluar el desempeño y pueden quitarlo.  

Discusión (Excelente, 0.9/1):  Bien. Explican los resultados con parsimonia, compuertas y calibración, comparan con [3] y [5] y proponen mejoras concretas. Sin embargo, ±10.58 % es la desviación estándar y no la varianza; la comparación con Maas et al. (88.89 %) no aclara que se hizo sobre otro conjunto de datos y otra partición; y el sobreajuste de la BiLSTM con fine-tuning y el desvanecimiento del gradiente se afirman sin respaldo (curvas de entrenamiento o un experimento controlado). Tampoco mencionan que el modelo final agotó las 30 épocas. Como recomendación, pueden incluir los transformers como referencia del estado del arte y como mejora.

Redacción y ortografía (Excelente, 0.8/1): El texto es técnico y no tiene errores ortográficos, pero está muy comprimido: hay oraciones muy largas (la última de la Introducción tiene unas 90 palabras) y párrafos de Metodología y Resultados que reúnen muchas ideas, cifras y paréntesis en una sola frase. Dividan esas oraciones en frases más cortas y directas, y conecten las ideas dentro de cada párrafo.

Formato (Excelente, 0.92/1): Siguen la plantilla IEEE con las secciones pedidas, tablas y figura con caption y referenciadas, y referencias completas. OJO con el orden de las citas: en IEEE se numeran según su primera aparición y aquí la primera es [3], seguida de [4], [1], [2] y [5]. Ubiquen cada tabla y figura dentro de su sección: la Tabla I, de Resultados, quedó sobre la continuación de la Metodología.

Código:

Entrega (Excelente, 1/1):Bien.

Orden (Excelente, 1/1):Bien. 

Nota final informe: 4.0/4.5  

Nota final código: 0.5/0.5  

Nota final: 4.5/5.0  

Nota final Coursera: 90.0/100  



