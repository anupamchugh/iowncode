import coremltools

output_labels = ['Cat', 'Dog']
coreml_model = coremltools.converters.keras.convert('model.h5', input_names=['image'], output_names=['output'],
                                                   class_labels=output_labels,
                                                   image_input_names='image')

coreml_model.author = 'Anupam Chugh'
coreml_model.short_description = 'Cat Dog Classifier converted from a Keras model'
coreml_model.input_description['image'] = 'Takes as input an image'
coreml_model.output_description['output'] = 'Prediction as cat or dog'
coreml_model.output_description['classLabel'] = 'Returns Cat Or Dog as class label'


coreml_model.save('catdogmodel.mlmodel')

coreml_model_path = "./catdogmodel.mlmodel"

spec = coremltools.utils.load_spec(coreml_model_path)
builder = coremltools.models.neural_network.NeuralNetworkBuilder(spec=spec)
builder.inspect_layers(last=3)
builder.inspect_input_features()

neuralnetwork_spec = builder.spec

neuralnetwork_spec.description.input[0].type.imageType.width = 150
neuralnetwork_spec.description.input[0].type.imageType.height = 150

# Set input and output description
neuralnetwork_spec.description.input[0].shortDescription = 'Takes as input an image'
neuralnetwork_spec.description.output[0].shortDescription = 'Prediction as cat or dog'

# Provide metadata
neuralnetwork_spec.description.metadata.author = 'Anupam Chugh'
neuralnetwork_spec.description.metadata.license = 'MIT'
neuralnetwork_spec.description.metadata.shortDescription = (
        'Cat Dog Classifier converted from a Keras model')


model_spec = builder.spec

# make_updatable method is used to make a layer updatable. It requires a list of layer names.
# dense_5 and dense_6 are two innerProduct layer in this example and we make them updatable.
builder.make_updatable(['dense_5', 'dense_6'])

# Categorical Cross Entropy or Mean Squared Error can be chosen for the loss layer.
builder.set_categorical_cross_entropy_loss(name='lossLayer', input='output')


# in addition of the loss layer, an optimizer must also be defined. SGD and Adam optimizers are supported.
# SGD has been used for this example. To use SGD, one must set lr(learningRate) and batch(miniBatchSize) (momentum is an optional parameter).
from coremltools.models.neural_network import SgdParams
builder.set_sgd_optimizer(SgdParams(lr=0.01, batch=5))

# The number of epochs must be set as follows.
builder.set_epochs(1)

model_spec.isUpdatable = True
model_spec.specificationVersion = coremltools._MINIMUM_UPDATABLE_SPEC_VERSION


# Set training inputs descriptions
model_spec.description.trainingInput[0].shortDescription = 'Image for training and updating the model'
model_spec.description.trainingInput[1].shortDescription = 'Set the value as Cat or Dog and update the model'


# save the updated spec
coremltools.utils.save_spec(model_spec, "CatDogUpdatable.mlmodel")
