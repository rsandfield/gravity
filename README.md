# Custom Gravity

Override and extend the standard physics gravity

## Introduction

Custom gravity should be used in place of the standard Area3D gravity. It reimplements the gravity system such that new types and interactions can be easily added.

## Getting Started

Remove standard gravity from your project: `Project > Physics > 3D > Default Gravity Vector = Vector3.ZERO`

Add a `GravityArea3D` node to your scene, give it a `CollisionShape3D` and set its `Gravity Resource` values however you wish. `RigidBodies` will now interact with the gravity area just as they would with standard `Area3D` gravity.

## Licenses

- Source code: [MIT License](/LICENSE).
- Godot logo: [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).
