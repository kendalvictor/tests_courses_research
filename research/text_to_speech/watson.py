from watson_developer_cloud import TextToSpeechV1

text_to_speech = TextToSpeechV1(
    iam_apikey='Lodh3fCgXG_yf7eP4ZyL-mifD65Eab6PXNZOCy1l6dIS',
    url='https://stream.watsonplatform.net/text-to-speech/api'
)

titulo = "1919: Alberto Ulloa"
h2 = "¿Qué se comentaba en el Diario El Comercio un día como hoy hace 100 años?"
#fecha = "<s>22 de Febrero del 2019</s>"
content = """
	<break time="1s"></break>
	Después de larga y penosa enfermedad, ha fallecido en la madrugada de hoy el doctor Alberto Ulloa, distinguido periodista que dirigió por más de diez años el diario “La Prensa”.
	El extinto desempeñó importantes cargos públicos, contándose entre ellos el de oficial mayor del Ministerio de Relaciones Exteriores y fue también ministro plenipotenciario del Perú en Colombia.
	Actualmente era diputado por Yauyos.
	El doctor Ulloa dirigió igualmente “El Tiempo”, periódico que se fusionó con “La Prensa” cuando él tomó la dirección de este último.
	Muere a los 56 años de edad.
"""


def get_mp3(titulo, h2, fecha, content, voz='es-LA_SofiaVoice'):
	cut_titulo = titulo.split(":")
	pre_titulo = cut_titulo[0]
	titulo = cut_titulo[1]

	texto = """
	<speak>
		<paragraph>
			<prosody rate="medium" volume="80">{0}</prosody>
			<prosody rate="medium" volume="120">{1}.</prosody>
		    <prosody volume="65"><s>{2}</s></prosody>
		    <prosody volume="65"><s>{3}</s></prosody>
	    	<prosody volume="85"><s>{4}</s></prosody>
	    </paragraph>
	</speak>
	""".format(
		pre_titulo, titulo, h2, fecha, content
	)

	with open('humberto_simple.mp3', 'wb') as audio_file:
	    audio_file.write(
	        text_to_speech.synthesize(
	            texto,
	            'audio/mp3',
	            voz
	        ).get_result().content
	)

voz_hombre = 'es-ES_EnriqueVoice'
voz_mujer = 'es-LA_SofiaVoice'
get_mp3(titulo, h2, '', content, voz=voz_hombre)




