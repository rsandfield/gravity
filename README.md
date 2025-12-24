# Custom Gravity

Override and extend the standard physics gravity

## Introduction

Custom gravity should be used in place of the standard Area3D gravity. It reimplements the gravity system such that new types and interactions can be easily added.

## Getting Started

Custom gravity can be used in tandem with the native Godot gravity system. However, any interactions between custom and native gravity will always be addative. To override native gravity, you have two options:
* Remove standard gravity from your project: `Project > Physics > 3D > Default Gravity Vector = Vector3.ZERO`
* On any `GravyArea3D` with which you wish to override native gravity, turn on the `Area3D` gravity with space mode `Replace` all values set to 0.

Add a `GravityArea3D` node to your scene, give it a `CollisionShape3D` and set its `Gravity Resource` values however you wish. `RigidBodies` will now interact with the gravity area just as they would with standard `Area3D` gravity. For `CharacterBody` scripts you will need to query the `GravityManager.get_gravity(body)` method instead of calling the `CharacterBody` native `get_gravity()` method.

## Licenses

- Source code: [MIT License](/LICENSE).
- Godot logo: [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).
