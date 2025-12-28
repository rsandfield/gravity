# Custom Gravity

Override and extend the standard physics gravity

## Introduction

Custom gravity should be used in place of the standard Area3D gravity. It reimplements the gravity system such that new types and interactions can be easily added.

## Getting Started

Custom gravity can be used in tandem with the native Godot gravity system. However, any interactions between custom and native gravity will always be addative. To override native gravity, you have two options:
* Remove standard gravity from your project: `Project > Physics > 3D > Default Gravity Vector = Vector3.ZERO`
* On any `GravyArea3D` with which you wish to override native gravity, turn on the `Area3D` gravity with space mode `Replace` all values set to 0.

Add a `GravityArea3D` node to your scene, give it a `CollisionShape3D` and set its `Gravity Resource` values however you wish. `RigidBodies` will now interact with the gravity area just as they would with standard `Area3D` gravity. For `CharacterBody` scripts you will need to query the `GravityManager.get_gravity(body)` method instead of calling the `CharacterBody` native `get_gravity()` method.

## Gravity Types

All gravity positions and directions are relative to their local transform, so do not need to be reconfigured if reoriented.

### Null

Useful as a placeholder or to create a zero-gravity area using priority override.

### Vector

Simply adds constant acceleration in a given direction.

### Point

A classic gravity well, can be inverted to push against the inside of a shell. Can either provide constant acceleration or will exponential dropoff.

### Cylinder

Pulls or pushes relative to an infinite line. Can either provide constant acceleration or will exponential dropoff.

### Capsule

Pulls or pushes relative to a finite line, with the caps acting like point gravity sources when 'outside' the start and end points. Can either provide constant acceleration or will exponential dropoff.

### Box

Pulls or pushes towards the shell of a cuboid. The edges act like cylinder gravity while the vertices act like point sources. This is more noticable when putting the shell 'inside' the body so that the edges and corners aren't razor thin at the ground, or when using inverted mode.

### Torus

Pulls or pushes towards a circle, forming a torroidal zone. Can either provide constant acceleration or will exponential dropoff.

### Adding a New Type

Extend the `Gravity` type and give a useful name to the new type. The `get_gravity_at(position: Vector3) -> Vector3` function must be implemented, other than that have fun. What would a Perlin noise gravity field look like?

## Gravity Modes

Gravity modes in this plugin are equivelant to the native gravity modes with one key difference. Instead of using the `Area3D` node's UID to break priority ties, the relative index location of nodes is used. The most recently entered node will always be the last member of the list of `GravityArea3D`s affecting a given body, allowing for a reliable and consistent behavior in line with certain popular adventure games with heavy gravity mechanics.

## Licenses

- Source code: [MIT License](/LICENSE).
- Godot logo: [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).
