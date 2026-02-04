package ${package}.controller;

import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Named;
import jakarta.inject.Inject;

import ${package}.model.Color;
import ${package}.repository.ColorRepository;

import java.util.List;

@Named
@RequestScoped
public class ColorController {

    @Inject
    private ColorRepository repository;

    public List<Color> getColors() {
        return repository.getAllColors();
    }

    private String name;
    private String greeting;

    public void submit() {
        greeting = "Hello, " + name + "!";
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
    
    public String getGreeting() {
        return greeting;
    }
}