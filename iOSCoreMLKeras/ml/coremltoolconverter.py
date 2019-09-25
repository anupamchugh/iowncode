import coremltools

coreml_model = coremltools.converters.keras.convert('model.h5', input_names=['image'], output_names=['output'],
                                                   image_input_names='image')

coreml_model.author = 'Anupam Chugh'
coreml_model.short_description = 'Cat Dog Classifier converted from a Keras model'
coreml_model.input_description['image'] = 'Takes as input an image'
coreml_model.output_description['output'] = 'Prediction as cat or dog'


coreml_model.save('catdogcoreml.mlmodel')
