package ${package}.repository;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.util.List;

import ${package}.model.Color;

@Stateless
public class ColorRepository {

    @PersistenceContext
    EntityManager entityManager;

    public List<Color> getAllColors() {
        return entityManager.createQuery("select c from Color c", Color.class)
                .getResultList();
    }
}