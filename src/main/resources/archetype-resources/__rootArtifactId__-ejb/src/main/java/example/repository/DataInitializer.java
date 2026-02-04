package ${package}.repository;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

import ${package}.model.Color;

@Startup
@Singleton
public class DataInitializer {

    @PersistenceContext
    EntityManager entityManager;

    @PostConstruct
    public void init() {
        List
                .of(
                        new Color("Red"),
                        new Color("Blue"),
                        new Color("Green")
                )
                .forEach(entityManager::persist);
    }
}