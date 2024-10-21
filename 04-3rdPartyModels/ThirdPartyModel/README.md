#  3rd Party Models

Kodeco AI Bootcamp, 4th homework, Using 3rd party models.

WARNING:
Please note that this app needs to be run on real iPhone device with minimum version of iOS 18.0.

Video walkthrough:
https://drive.google.com/file/d/1aRvfAzUrqBdAotW4ZyqMVdR-ePqVSyR8/view?usp=sharing

Models:
*) yolov8x-cls-full-300: original model
model.export(format="coreml", nms=True, imgsz=300, optimize=True)

*) yolov8x-cls-int8-300: model compressed by quantization technique: form Float16 to Int8
model.export(format="coreml", nms=True, imgsz=300, int8=True, optimize=True)

