import React, { useState } from 'react';
import {
  View,
  TouchableOpacity,
  Text,
  ScrollView,
  StyleSheet,
} from 'react-native';

export default function Select({
  options,
  selectedValue,
  onSelect,
  placeholder = '— select —',
}: {
  options: string[];
  selectedValue: string | undefined;
  onSelect: (value: string) => void;
  placeholder?: string;
}) {
  const [open, setOpen] = useState(false);

  return (
    <View style={[styles.container, open && styles.containerOpen]}>
      <TouchableOpacity
        style={styles.button}
        onPress={() => setOpen(!open)}
        activeOpacity={0.7}
      >
        <Text style={styles.buttonText}>
          {selectedValue ? selectedValue.slice(0, 8) + '…' : placeholder}
        </Text>
        <Text style={styles.arrow}>{open ? '▲' : '▼'}</Text>
      </TouchableOpacity>
      {open && (
        <ScrollView style={styles.list} nestedScrollEnabled>
          {options.length === 0 ? (
            <Text style={styles.emptyText}>No options</Text>
          ) : (
            options.map((value) => (
              <TouchableOpacity
                key={value}
                style={[
                  styles.item,
                  value === selectedValue && styles.itemSelected,
                ]}
                onPress={() => {
                  onSelect(value);
                  setOpen(false);
                }}
              >
                <Text
                  style={[
                    styles.itemText,
                    value === selectedValue && styles.itemTextSelected,
                  ]}
                >
                  {value.slice(0, 8)}…
                </Text>
              </TouchableOpacity>
            ))
          )}
        </ScrollView>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { marginBottom: 8 },
  containerOpen: { zIndex: 99999 },
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: '#fff',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#ccc',
    minWidth: 180,
    alignSelf: 'flex-start',
  },
  buttonText: { fontSize: 13, color: '#333' },
  arrow: { fontSize: 10, color: '#666', marginLeft: 8 },
  list: {
    position: 'absolute',
    top: 36,
    left: 0,
    minWidth: 180,
    maxHeight: 200,
    backgroundColor: '#fff',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#ccc',
    shadowColor: '#000',
    shadowOpacity: 0.15,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 2 },
  },
  emptyText: {
    fontSize: 13,
    color: '#999',
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  item: { paddingHorizontal: 12, paddingVertical: 8 },
  itemSelected: { backgroundColor: '#007AFF', borderRadius: 4 },
  itemText: { fontSize: 13, color: '#333', fontFamily: 'Menlo' },
  itemTextSelected: { color: '#fff' },
});
